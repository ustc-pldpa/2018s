open Core

type direction = Left | Right
[@@deriving sexp_of, sexp, compare]

type binop = Add | Sub | Mul | Div
[@@deriving sexp_of, sexp, compare]

module Lang = struct
  module Type = struct
    type t =
      | Int
      | Var of string
      | Fn of t * t
      | Sum of t * t
      | Product of t * t
      | ForAll of string * t
      | Exists of string * t
    [@@deriving sexp_of, sexp, compare]

    let to_string t = Sexp.to_string_hum (sexp_of_t t)
  end

  module Pattern = struct
    type t =
      | Wildcard
      | Var of string * Type.t
      | Alias of t * string * Type.t
      | Tuple of t * t
      | TUnpack of string * string
    [@@deriving sexp_of, sexp, compare]

    let to_string t = Sexp.to_string_hum (sexp_of_t t)
  end

  module Term = struct
    type t =
      | Int of int
      | Var of string
      | Lam of string * Type.t * t
      | App of t * t
      | Binop of binop * t * t
      | Tuple of t * t
      | Project of t * direction
      | Inject of t * direction * Type.t
      | Let of Pattern.t * t * t
      | Match of t * (Pattern.t * t) * (Pattern.t * t)
      | TLam of string * t
      | TApp of t * Type.t
      | TPack of Type.t * t * Type.t
    [@@deriving sexp_of, sexp, compare]

    let to_string t = Sexp.to_string_hum (sexp_of_t t)
  end
end

module IR = struct
  module Type = struct
    type t =
      | Int
      | Var of string
      | Fn of t * t
      | Product of t * t
      | Sum of t * t
      | ForAll of string * t
      | Exists of string * t
    [@@deriving sexp_of, sexp, compare]

    let to_string t = Sexp.to_string_hum (sexp_of_t t)

    let rec substitute (x : string) (tau' : t) (tau : t) : t =
      match tau with
      | Int -> tau
      | Var x' -> if x = x' then tau' else tau
      | Fn (tau1, tau2) -> Fn (substitute x tau' tau1, substitute x tau' tau2)
      | Product (tau1, tau2) -> Product (substitute x tau' tau1, substitute x tau' tau2)
      | Sum (tau1, tau2) -> Sum (substitute x tau' tau1, substitute x tau' tau2)
      | ForAll (x', tau_all) ->
        if x = x' then tau
        else ForAll(x', substitute x tau' tau_all)
      | Exists (x', tau_exists) ->
        if x = x' then tau
        else Exists(x', substitute x tau' tau_exists)

    let to_debruijn (tau : t) : t =
      let rec aux (depths : int String.Map.t) (tau : t) =
        let same_depth = aux depths in
        let incr_depth x tau =
          aux
            (String.Map.add
               (String.Map.map depths ~f:(fun x -> x + 1))
               ~key:x
               ~data:0)
          tau
        in
        match tau with
        | Int -> Int
        | Var x ->
          Var (Int.to_string (
            match String.Map.find depths x with
            | Some n -> n
            | None -> 0))
        | Fn (tau1, tau2) -> Fn (same_depth tau1, same_depth tau2)
        | Product (tau1, tau2) -> Product (same_depth tau1, same_depth tau2)
        | Sum (tau1, tau2) -> Sum (same_depth tau1, same_depth tau2)
        | ForAll (x, tau) -> ForAll(x, incr_depth x tau)
        | Exists (x, tau) -> Exists(x, incr_depth x tau)
      in
      aux String.Map.empty tau

    let aequiv (tau1 : t) (tau2 : t) : bool =
      let rec aequiv_aux (tau1 : t) (tau2 : t) : bool =
        match (tau1, tau2) with
        | (Int, Int) -> true
        | (Var x, Var x') -> x = x'
        | (Fn (arg1, ret1), Fn (arg2, ret2)) ->
          aequiv_aux arg1 arg2 && aequiv_aux ret1 ret2
        | (Product (l1, r1), Product (l2, r2)) ->
          aequiv_aux l1 l2 && aequiv_aux r1 r2
        | (Sum (l1, r1), Sum (l2, r2)) ->
          aequiv_aux l1 l2 && aequiv_aux r1 r2
        | (ForAll(_, tau1), ForAll(_, tau2)) ->
          aequiv_aux tau1 tau2
        | (Exists(_, tau1), Exists(_, tau2)) ->
          aequiv_aux tau1 tau2
        | _ -> false
      in
      aequiv_aux (to_debruijn tau1) (to_debruijn tau2)

    let inline_tests () =
      assert (aequiv Int Int);
      assert (aequiv (Fn (Int, Int)) (Fn (Int, Int)));
      assert (aequiv (ForAll ("x", Var "x")) (ForAll ("y", Var "y")));
      assert (aequiv (
        ForAll ("x", Fn(Var "x", ForAll("y", Fn(Var "x", Var "y")))))
        (ForAll ("y", Fn(Var "y", ForAll("x", Fn(Var "y", Var "x"))))))

    let () = inline_tests ()
  end

  module Term = struct
    type t =
      | Int of int
      | Var of string
      | Lam of string * Type.t * t
      | App of t * t
      | Binop of binop * t * t
      | Tuple of t * t
      | Project of t * direction
      | Inject of t * direction * Type.t
      | Case of t * (string * t) * (string * t)
      | TLam of string * t
      | TApp of t * Type.t
      | TPack of Type.t * t * Type.t
      | TUnpack of string * string * t * t
    [@@deriving sexp_of, sexp, compare]

    let to_string t = Sexp.to_string_hum (sexp_of_t t)

    let rec substitute x t' t =
      match t with
      | Int _ -> t
      | Var x' -> if x = x' then t' else t
      | Lam (x', ty, body) -> if x = x' then t else Lam (x', ty, substitute x t' body)
      | App (t1, t2) -> App (substitute x t' t1, substitute x t' t2)
      | Binop (b, t1, t2) -> Binop (b, substitute x t' t1, substitute x t' t2)
      | Tuple (t1, t2) -> Tuple (substitute x t' t1, substitute x t' t2)
      | Project (t, dir) -> Project (substitute x t' t, dir)
      | Inject (t, dir, tau) -> Inject (substitute x t' t, dir, tau)
      | Case (t, (x1, t1), (x2, t2)) ->
        Case (substitute x t' t,
              (x1, if x = x1 then t1 else substitute x t' t1),
              (x2, if x = x2 then t2 else substitute x t' t2))
      | TLam (v, t) -> TLam (v, substitute x t' t)
      | TApp (t, tau) -> TApp (substitute x t' t, tau)
      | TPack (tau1, t, tau2) -> TPack (tau1, substitute x t' t, tau2)
      | TUnpack (xterm, xty, arg, body) ->
        TUnpack (xterm, xty, substitute x t' arg, substitute x t' body)
  end
end
