open Core
open Result.Monad_infix
open Ast

let parse input =
  let filebuf = Lexing.from_string input in
  try (Ok (Parser.main Lexer.token filebuf)) with
  | Lexer.Error msg -> Error msg
  | Parser.Error -> Error (
    Printf.sprintf "Parse error: %d" (Lexing.lexeme_start filebuf))

let run filename =
  let input = In_channel.read_all filename in
  let result = parse input
    >>= fun term ->
    Printf.printf "Term: %s\n" (Lang.Term.to_string term);
    let term = Translator.translate term in
    Printf.printf "Translated: %s\n" (IR.Term.to_string term);
    Typechecker.typecheck term
    >>= fun ty ->
    Printf.printf "Type: %s\n" (IR.Type.to_string ty);
    Interpreter.eval term
  in
  match result with
  | Ok e -> Printf.printf "Success: %s\n" (IR.Term.to_string e)
  | Error s -> Printf.printf "Error: %s\n" s

let main () =
  let open Command.Let_syntax in
  Command.basic'
    ~summary:"Lam2 interpreter"
    [%map_open
      let filename = anon ("filename" %: string) in
      fun () -> run filename
    ]
  |> Command.run

let () = main ()
