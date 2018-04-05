open Core
open Ast

exception Unimplemented

let rec translate_type (t : Lang.Type.t) : IR.Type.t =
  match t with
  | Lang.Type.Int -> IR.Type.Int
  | Lang.Type.Var v -> IR.Type.Var v
  | Lang.Type.Fn (l, r) -> IR.Type.Fn (translate_type l, translate_type r)
  | Lang.Type.Product (l, r) -> IR.Type.Product (translate_type l, translate_type r)
  | Lang.Type.Sum (l, r) -> IR.Type.Sum (translate_type l, translate_type r)
  | Lang.Type.ForAll (x, t) -> IR.Type.ForAll (x, translate_type t)
  | Lang.Type.Exists (x, t) -> IR.Type.Exists (x, translate_type t)

(* translate_term converts a term from the top-level language (Lang.Term.t) into
 * a term in the intermediate representation (IR.Term.t). The conversion primarily
 * eliminates pattern matching. We have implemented the Match case for you, now it
 * is up to you to define the translation for Let. *)
let rec translate_term (t : Lang.Term.t) : IR.Term.t =
  match t with
  (* These translations are trivial (nothing changes), so we have implemented them
   * for you. *)
  | Lang.Term.Int n -> IR.Term.Int n
  | Lang.Term.Var v -> IR.Term.Var v
  | Lang.Term.Lam (v, t, e) -> IR.Term.Lam (v, translate_type t, translate_term e)
  | Lang.Term.App (l, r) -> IR.Term.App (translate_term l, translate_term r)
  | Lang.Term.Binop (b, l, r) -> IR.Term.Binop (b, translate_term l, translate_term r)
  | Lang.Term.Tuple (l, r) -> IR.Term.Tuple (translate_term l, translate_term r)
  | Lang.Term.Project (t, dir) ->
    IR.Term.Project (translate_term t, dir)
  | Lang.Term.Inject (t, dir, tau) ->
    IR.Term.Inject (translate_term t, dir, translate_type tau)
  | Lang.Term.TLam (v, e) -> IR.Term.TLam (v, translate_term e)
  | Lang.Term.TApp (e, t) -> IR.Term.TApp (translate_term e, translate_type t)
  | Lang.Term.TPack (t1, e, t2) ->
    IR.Term.TPack (translate_type t1, translate_term e, translate_type t2)

  | Lang.Term.Match (t, (p1, t1), (p2, t2)) ->
    (* Read this case carefully to understand how it maps to the translation rules
     * provided in the handout. *)
    let t' = translate_term t in
    let t1' = translate_term (Lang.Term.Let (p1, Lang.Term.Var "x1", t1)) in
    let t2' = translate_term (Lang.Term.Let (p2, Lang.Term.Var "x2", t2)) in
    IR.Term.Case (t', ("x1", t1'), ("x2", t2'))

  | Lang.Term.Let (p, arg, body) ->
    (* Delete the line below and implement the Let case. *)
    raise Unimplemented

let translate t = translate_term t

let inline_tests () =
  assert (translate_term (Lang.Term.Int 3) = IR.Term.Int 3);

  let t =
    Lang.Term.Let (
      Lang.Pattern.Var ("x", Lang.Type.Int),
      Lang.Term.Int 3,
      Lang.Term.Var "x")
  in
  let t' =
    IR.Term.App (
      IR.Term.Lam ("x", IR.Type.Int, IR.Term.Var "x"),
      IR.Term.Int 3)
  in
  assert (translate_term (t) = t')

let () = inline_tests ()
