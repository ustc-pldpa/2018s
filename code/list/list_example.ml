open Core

(* The goal of this part of the lecture is to understand how OCaml lists work and
 * understand how to map imperative control flow on lists into functional constructs. *)

let print_int_list l =
  Printf.printf "%s\n" (List.to_string string_of_int l)

let print_int_pair_list l =
  Printf.printf "%s\n" (List.to_string (fun (i, j) -> Printf.sprintf "(%d, %d)" i j) l)

let () =
  (* We can create lists with the usual syntax, except semicolons instead of commas *)
  let l = [1; 2; 3] in

  (* Lists in OCaml are not like lists in other languages--they're more like linked lists.
   * Subsequently, you cannot by default access the i-th element of a list. You can only
   * pop off elements one at a time. More generally, a list is actually a sum type!
   * A list is either the empty list [] or it's an element plus the rest of the list,
   * written like x :: l' read as "x cons l prime" (the :: is called "cons"). *)

  (* Look at sum_list in list.lua--how we normally think about iterating over lists is
   * with for loops. However we don't use for loops in functional languages, we use
   * recursion instead! Here's an example of writing a function that adds all the elements
   * of a list together. *)
  let rec sum_list (l : int list) : int =
    match l with
    | [] -> 0  (* the base case (empty list) is 0 *)
    | x :: l' -> x + (sum_list l') (* the recursive case sums up the rest of the list *)
  in

  (* Similarly, let's say we want to update all the elements in our list, e.g. to add
   * 1 to each element. In an imperative language we would usually modify our list
   * in-place, e.g. t[i] = t[i] + 1, but in a functional language everything is immutable.
   * We don't change existing things, we only make new ones. So our incr_list function
   * actually constructs a new list. *)
  let rec incr_list (l : int list) : int list =
    match l with
    | [] -> []
    | x :: l' -> (x + 1) :: (incr_list l')
  in

  Printf.printf "%d\n" (sum_list [1; 2; 3]);
  print_int_list (incr_list [1; 2; 3]);

  (* However, it would be annoying/verbose if every time you wanted to express a simple
   * for loop, you had to write a full-on recursive function. Instead, we use a standard
   * library that comes equipped with functions that match various common operations on
   * lists. For example, one common operation is to transform every element of a list
   * with some common function, e.g. in the incr_list case, we want to add 1 to each
   * element. This is often called a "map", specifically using the function:
   *   List.map : ('a -> 'b) -> 'a list -> 'b list
   * This says: map takes a function that takes some function ('a -> 'b) and a list of
   * 'a elements, and then returns a list of 'b elements. Here, 'a = 'b = int, but they
   * could be any type. That's the power of polymorphism! *)
  let incr_list (l : int list) : int list =
    (* Note that "~" is the way of writing named arguments in OCaml. *)
    List.map ~f:(fun x -> x + 1) l
  in

  (* Map is not a complicated function--we could implement it ourselves if we wanted
   * to. It's just convenient to have around in a standard library. *)
  let rec map (f : 'a -> 'b)  (l : 'a list) : 'b list =
    match l with
    | [] -> []
    | x :: l' -> (f x) :: (map f l')
  in

  (* Note that we can use currying, or partial function application, create the function
   * without ever explicitly specifying the list parameter. *)
  let incr_list : int list -> int list = List.map ~f:(fun x -> x + 1) in

  (* Map is one pattern, but there are others we would like to capture. For example,
   * summing a list uses what's called a "fold", which basically means accumulating
   * some value across each element of this list.
   *   List.fold : 'accum -> ('accum -> 'a -> 'accum) -> 'a list -> 'accum
   * Fold takes an initial value an initial value for the accumulator, and then iteratively
   * applies the folding function with the accumulator on each element. For example:
   *  List.fold ~init:0 ~f:f [1; 2; 3] = f (f (f 0 1) 2) 3 *)
  let sum_list (l : int list) : int =
    List.fold ~init:0 ~f:(fun sum x -> sum + x) l
  in

  (* One last important pattern: sometimes we want to remove elements from a
   * list based on some condition, e.g. if we want to remove all the odd
   * numbers from a list of numbers. We can express this as a List.filter:
   *   List.filter : ('a -> bool) -> 'a list -> 'a list *)
  let even_list (l : int list) : int list =
    List.filter ~f:(fun x -> x mod 2 = 0) l
  in

  print_int_list (even_list [1; 2; 3])
