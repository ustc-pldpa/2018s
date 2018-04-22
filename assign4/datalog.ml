open Core

exception Unimplemented

module Term = struct
  type t = Var of string | Symbol of string [@@deriving sexp, compare]

  let to_string = function
    | Var v -> v
    | Symbol s -> s
end

module Relation = struct
  module T = struct
    type t = {
      pred : string;
      terms : Term.t list;
    } [@@deriving sexp, compare]
  end

  include T
  module Set = Set.Make(T)

  let to_string t =
    let term_str = String.concat ~sep:", " (List.map t.terms ~f:Term.to_string) in
    t.pred ^ "(" ^ term_str ^ ")"
end

module Rule = struct
  type t = {
    head : Relation.t;
    body : Relation.t list;
  } [@@deriving sexp]

  let to_string t =
    let body = String.concat ~sep:", " (List.map t.body ~f:Relation.to_string) in
    (Relation.to_string t.head) ^ " :- " ^ body
end

module Program = struct
  type t = Rule.t list * Relation.t list [@@deriving sexp]

  let to_string t =
    let rules = String.concat ~sep:"\n" (List.map (fst t) ~f:Rule.to_string) in
    let facts = String.concat ~sep:"\n" (List.map (snd t) ~f:Relation.to_string) in
    facts ^ "\n\n" ^ rules
end

module type Database = sig
  type t
  val build : Program.t -> t
  val query : t -> Relation.t -> Relation.t list
  val facts : t -> Relation.t list
end

(* env is a mapping from variables to terms (either variables or symbols) *)
type env = Term.t Union_find.t String.Map.t
let empty_env = String.Map.empty

(* unify : env -> Relation.t -> Relation.t -> env
 * This function takes a starting environment (could be empty) and
 * attempts to unify the two terms, adding the necessary substitutions
 * to the environment. Ignoring OCaml syntax for a moment, here's an example:
 *   unify {} likes(ava, X) likes(Y, Z) = {Y -> ava, X -> Z}
 * If the two relations cannot unify, then this function raises CannotUnify. *)
exception CannotUnify
let unify (env : env) (r1 : Relation.t) (r2 : Relation.t) : env =
  if r1.pred <> r2.pred then raise CannotUnify
  else
    List.fold (List.zip_exn r1.terms r2.terms) ~init:env ~f:(fun env terms ->
      match terms with
      | (Symbol a, Symbol b) -> if a = b then env else raise CannotUnify
      | (Var a, Var b) ->
        (match (String.Map.find env a, String.Map.find env b) with
         | (Some x, Some y) -> Union_find.union x y; env
         | (Some x, None) -> String.Map.add env ~key:b ~data:x
         | (None, Some y) -> String.Map.add env ~key:a ~data:y
         | (None, None) ->
           let cls = Union_find.create (Term.Var a) in
           String.Map.add
             (String.Map.add env ~key:a ~data:cls)
             ~key:b
             ~data:cls)
      | ((Var x, Symbol a) | (Symbol a, Var x)) ->
        (match String.Map.find env x with
         | Some x -> (match Union_find.get x with
           | Term.Symbol a' -> if a <> a' then raise CannotUnify else env
           | Term.Var _ -> Union_find.set x (Term.Symbol a); env)
         | None -> String.Map.add env ~key:x ~data:(Union_find.create (Term.Symbol a))))

(* substitute : Relation.t -> env -> Relation.t
 * This function takes a relation and applies the environment to substitute
 * all relevant variables. For example:
 *   substitute likes(X, Y) {Y -> john} = likes(X, john) *)
let substitute (l : Relation.t) (env : env) : Relation.t =
  let rec iter terms =
    let new_terms = List.map terms ~f:(fun term ->
      match term with
      | Term.Var x -> (match String.Map.find env x with
        | Some y -> (match Union_find.get y with
          | Term.Symbol y' -> Term.Symbol y'
          | _ -> raise (Failure "bad subst"))
        | None -> term)
      | Symbol _ -> term)
    in
    if List.for_all2_exn terms new_terms ~f:(=) then
      terms
    else iter new_terms
  in
  {pred = l.pred; terms = iter l.terms}

(* applicable_facts : Relation.Set.t -> Relation.t Relation.t
 * This function returns a list of all facts (relations) in the input set
 * that have the same name as the target. For example:
 *   applicable_facts {likes(john, mary), hates(tom, jerry)} likes(foo, bar)
 *     = [likes(john, mary)] *)
let applicable_facts (facts : Relation.Set.t) (relation : Relation.t) : Relation.t list =
  List.filter (Relation.Set.to_list facts) ~f:(fun fact ->
    fact.pred = relation.pred)

(* cross_product : 'a list list -> 'a list list
 * This function returns the cross product of all input lists. For example:
 *   cross_product [[1; 2]; [3; 4]; [5; 6]] =
 *     [[1; 3; 5]; [1; 3; 6]; [1; 4; 5]; [1; 4; 6];
 *      [2; 3; 5]; [2; 3; 6]; [2; 4; 5]; [2; 4; 6]] *)
let rec cross_product (lists : 'a list list) : 'a list list =
  match lists with
  | [] -> raise (Failure "Can't generate a cross product of zero input lists.")
  | [l] -> List.map l ~f:(fun x -> [x])
  | [] :: _ -> []
  | l :: ls ->
    let cs = cross_product ls in
    List.reduce_exn (List.map l ~f:(fun x ->
      (List.map cs ~f:(fun xl -> x :: xl))))
      ~f:(@)

module DatabaseImpl : Database = struct
  type t = Relation.t list

  let facts t = t

  let saturate (rules : Rule.t list) (facts : Relation.Set.t) : Relation.Set.t =
    (* Your code here. *)
    raise Unimplemented


  let build ((rules, facts) : Program.t) : t =
    Relation.Set.to_list (saturate rules (Relation.Set.of_list facts))

  let  query (facts : t) (q : Relation.t) : Relation.t list =
    (* Your code here. *)
    raise Unimplemented

end

let run_saturation filename =
  let input = In_channel.read_all filename in
  let program = input |> Sexp.of_string |> Program.t_of_sexp  in
  let db = DatabaseImpl.build program in
  let output = String.concat ~sep:"\n" (List.map (DatabaseImpl.facts db) ~f:(fun r ->
   (Relation.to_string r) ^ ".")) in
  Printf.printf "%s\n" output

let run prog_filename query_filename =
  let program = prog_filename |> In_channel.read_all |> Sexp.of_string |> Program.t_of_sexp  in
  let query = query_filename |> In_channel.read_all |> Sexp.of_string |> Relation.t_of_sexp  in
  let db = DatabaseImpl.build program in
  let answers = DatabaseImpl.query db query in
  let output = String.concat ~sep:"\n" (List.map answers ~f:(fun r ->
   (Relation.to_string r) ^ ".")) in
  Printf.printf "%s\n" output

let print_program prog_filename =
  let program = prog_filename |> In_channel.read_all |> Sexp.of_string |> Program.t_of_sexp  in
  Printf.printf "%s\n" (Program.to_string program)

let print_query query_filename =
  let query = query_filename |> In_channel.read_all |> Sexp.of_string |> Relation.t_of_sexp  in
  Printf.printf "%s\n" (Relation.to_string query)

let main () =
  let open Command.Let_syntax in
  Command.group ~summary:"Datalog Interpreter"
  ["test-saturation", Command.basic' ~summary:"Test saturation only."
      [%map_open
        let filename = anon ("program_filename" %: string) in
        fun () -> run_saturation filename];
  "print-program", Command.basic' ~summary:"Print an s-expression program in readable form."
      [%map_open
        let filename = anon ("program_filename" %: string) in
        fun () -> print_program filename];
  "print-query", Command.basic' ~summary:"Print an s-expression query in readable form."
      [%map_open
        let filename = anon ("query_filename" %: string) in
        fun () -> print_query filename];
  "test", Command.basic' ~summary:"Test saturation and query implementations."
      [%map_open
        let prog_filename = anon ("program_filename" %: string)
        and query_filename = anon ("query_filename" %: string) in
        fun () -> run prog_filename query_filename]]
  |> Command.run

let () = main ()
