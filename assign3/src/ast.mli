open Core

type direction = Left | Right
[@@deriving sexp_of, sexp, compare]

type binop = Add | Sub | Mul | Div
[@@deriving sexp_of, sexp, compare]

module Lang : sig
  module Type : sig
    type t =
      | Int
      | Var of string
      | Fn of t * t
      | Sum of t * t
      | Product of t * t
      | ForAll of string * t
      | Exists of string * t
    [@@deriving sexp_of, sexp, compare]

    val to_string : t -> string
  end

  module Pattern : sig
    type t =
      | Wildcard
      | Var of string * Type.t
      | Alias of t * string * Type.t
      | Tuple of t * t
      | TUnpack of string * string
    [@@deriving sexp_of, sexp, compare]

    val to_string : t -> string
  end

  module Term : sig
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

    val to_string : t -> string
  end
end

module IR : sig
  module Type : sig
    type t =
      | Int
      | Var of string
      | Fn of t * t
      | Product of t * t
      | Sum of t * t
      | ForAll of string * t
      | Exists of string * t
    [@@deriving sexp_of, sexp, compare]

    val to_string : t -> string

    val aequiv : t -> t -> bool

    val substitute : string -> t -> t -> t
  end

  module Term : sig
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

    val to_string : t -> string

    val substitute : string -> t -> t -> t
  end
end
