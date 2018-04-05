open Core
open Ast.IR

type outcome =
  | Step of Term.t
  | Val
  | Err of string

val trystep : Term.t -> outcome
val eval : Term.t -> (Term.t, string) Result.t
