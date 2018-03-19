(***** EXPRESSION BASICS ******)

(* Note: type declarations have to be at the top level *)
type my_type = A of int | B of string
type int_option = Some of int | None
type int_list = Cons of int * int_list | Empty
type binary_tree = Leaf of int | Node of binary_tree * binary_tree

let main () =
    (* Let expression with type annotation *)
    let x : int = 2 in

    (* Variable scoping *)
    let y : int = x + 1 in

    let x =
      let x =
        let x = 2 in
        x + 1
      in
      x + 1
    in


    (* Type inference *)
    let z = 3 in
    (* let z : string = 3 in *)

    (* Other types *)
    let s : string = "hello world" in
    let b : bool = false in
    let n : float = 3.0 in

    (* Functions *)
    let add_one : int -> int = fun (n : int) -> n + 1 in
    let add_one = fun n -> n + 1 in
    let add_one (n : int) : int = n + 1 in
    let add_one n = n + 1 in

    (* Currying *)
    let add_k k n = k + n in

    let add_one = add_k 1 in
    let add_five = add_k 5 in

    (* Recursive functions *)
    (* Note that equality is =, not == *)
    let rec fact n =
      if n = 0 then 1
      else n * (fact (n - 1))
    in

    (* If statements *)
    let x = if 3 > 2 then "true" else "not true" in

    (* Helper functions to emulate loops *)
    let is_prime n =
      let rec check_num i =
        if i = n then true
        else if n mod i = 0 then false
        else check_num (i + 1)
      in
      check_num 2
    in

    (* Match statements *)
    let rec fib n =
      match n with
      | 0 -> 0
      | 1 -> 1
      | _ -> (fib (n - 1)) + (fib (n - 2))
    in

    (* EXERCISES:
     * val clamp : int -> int -> int -> int
     *   clamp lower upper n = returns n clamped to range [lower, upper]
     * val sum_to : int -> int
     *   sum_to n = adds all the numbers from 1 to n (don't use the closed form) *)

    let clamp lower upper n =
      if n < lower then lower
      else if n > upper then upper
      else n
    in

    let rec sum_to n =
      if n = 0 then 0
      else n + (sum_to (n - 1))
    in

    (****** COMPOSITE DATA TYPES *****)

    (* Tuples *)
    let tuple : int * string * int = (1, "two", 3) in
    let (x, y, z) = tuple in
    let n = match tuple with
      | (_, _, 1) -> 1
      | _ -> 2
    in

    (* Currying vs. tuples *)
    let f (a, b) = a + b in
    let f a b = a + b in

    (* List *)
    let l : int list = [1; 2; 3] in

    let head (l : int list) : int = match l with
      | [] -> raise (Failure ("No elements in list"))
      | x :: l' -> x
    in

    let rec sum_list l =
      match l with
      | [] -> 0
      | x :: l' -> x + (sum_list l')
    in

    (* EXERCISES:
     * val map : int list -> (int -> int) -> int list
     *   map l f = returns l' with f applied to each element
     *)

    let rec map l f =
      match l with
      | [] -> []
      | x :: l' -> (f x) :: (map l' f)
    in

    (* Option types *)
    let try_div m n =
      if n = 0 then None
      else Some (m / n)
    in

    let () = match try_div 5 0 with
      | Some n -> Printf.printf "%d\n" n
      | None -> Printf.printf "bad div!\n"
    in

    (* Sum types *)
    let l = 1 :: 2 :: [] in
    let l' = Cons (1, Cons (2, Empty)) in

    ()

let () = main()
