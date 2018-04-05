open Core
open Ast

val typecheck : IR.Term.t -> (IR.Type.t, string) Result.t
