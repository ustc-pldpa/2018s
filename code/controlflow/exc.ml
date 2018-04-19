(* Basic exception raising *)
let () =
  raise (Failure "Fail!")

(* Catching exceptions *)
let () =
  try
    raise (Failure "Fail!")
  with
  | Failure s -> print_string ("Found failure: " ^ s)

(* try/with is a value! *)
let () =
  let x =
    try
      5 / 0
    with
    | Division_by_zero -> 0
  in
  print_int (x + 1)

(* exceptions cross boundaries *)
let () =
  let g y = raise (Failure "") in
  let f x = g x in
  try print_int (f 0) with
  | Failure s -> print_string "Two-level failure"

(* backtracking search with exceptions *)
let rec subset_sum (numbers : int list) (target : int) : int list option =
  match (numbers, target) with
  | (_, 0) -> Some []
  | ([], _) -> None
  | (n :: numbers', _) ->
    match (subset_sum numbers' (target - n)) with
    | Some sol -> Some (n :: sol)
    | None -> subset_sum numbers' target

exception NoSum
let rec subset_sum_exn (numbers : int list) (target : int) : int list =
  match (numbers, target) with
  | (_, 0) -> []
  | ([], _) -> raise NoSum
  | (n :: numbers', _) ->
    try
      (n :: subset_sum_exn numbers' (target - n))
    with NoSum -> subset_sum_exn numbers' target

let () =
  print_int (List.nth (subset_sum_exn [1;2;3] 8) 0)
