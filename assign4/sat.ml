open Core

type literal = string * bool        [@@deriving sexp_of, sexp, compare]
type clause = literal list          [@@deriving sexp_of, sexp, compare]
type cnf = clause list              [@@deriving sexp_of, sexp, compare]
type assignment = bool String.Map.t [@@deriving sexp_of, sexp, compare]

(* satisfiable : cnf -> assignment option
 * This function takes a conjunctive normal form boolean statement and attempts
 * to find a satisfying assignment, returning Some(assignment) if one exists
 * and None otherwise. *)
let satisfiable (atoms : string list) (cnf : cnf) : assignment option =
  let rec iter_cnf (assignment : assignment) (cnf : cnf) : assignment option =
    match cnf with
    | [] -> Some (List.fold atoms ~init:assignment ~f:(fun assignment atom ->
      match String.Map.find assignment atom with
      | None -> String.Map.add assignment ~key:atom ~data:true
      | Some _ -> assignment))
    | clause :: cnf' ->
      List.fold clause ~init:None ~f:(fun acc (atom, affinity) ->
        (match (acc, String.Map.find assignment atom) with
         | (Some _, _) -> acc
         | (_, None) ->
           iter_cnf (String.Map.add assignment ~key:atom ~data:affinity) cnf'
         | (_, Some affinity') ->
           if affinity = affinity' then iter_cnf assignment cnf'
           else None))
  in iter_cnf String.Map.empty cnf


let inline_tests () =
  let check_if_satisfies (cnf : cnf) (assignment : assignment) : bool =
    List.fold cnf ~init:true ~f:(fun b clause ->
      let satisfies = List.fold clause ~init:false ~f:(
        fun b' (atom, affinity) ->
          (match String.Map.find assignment atom with
           | None -> raise (
             Failure (Printf.sprintf "Assignment missing atom %s" atom))
           | Some affinity' -> affinity = affinity' || b'))
      in satisfies && b)
  in

  let cnf = [[("a", true); ("b", false)];
             [("c", true); ("b", true)];
             [("b", true)]] in
  let atoms = ["a"; "b"; "c"] in

  match satisfiable atoms cnf with
  | Some assignment -> assert(check_if_satisfies cnf assignment)
  | None -> raise (Failure "No satisfying assignment")

let () = inline_tests()
