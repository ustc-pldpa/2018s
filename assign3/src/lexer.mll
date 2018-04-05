{
  open Parser
  exception Error of string
}

rule token = parse
| [' ' '\t' '\n'] { token lexbuf }
| '.' { DOT }
| '(' { LPAREN }
| ')' { RPAREN }
| '[' { LBRACKET }
| ']' { RBRACKET }
| '{' { LBRACE }
| '}' { RBRACE }
| '*' { STAR }
| '=' { EQUAL }
| '_' { WILDCARD }
| ',' { COMMA }
| '+' { PLUS }
| '-' { SUB }
| '/' { DIV }
| '|' { BAR }
| 'R' { RIGHT }
| 'L' { LEFT }
| "match" { MATCH }
| "fn" { FN }
| "as" { AS }
| "in" { IN }
| "let" { LET }
| "tfn" { TFN }
| "int" { TY_INT }
| "forall" { FORALL }
| "exists" { EXISTS }
| "inj" { INJECT }
| "->" { ARROW }
| ":" { COLON }
| ['a'-'z''A'-'Z']['a'-'z''A'-'Z''0'-'9']* as v { VAR v }
| ['0'-'9']+ as i { INT (int_of_string i) }
| "(*" _* "*)" { token lexbuf }
| eof { EOF }
| _ { raise (Error (Printf.sprintf "At offset %d: unexpected character.\n" (Lexing.lexeme_start lexbuf))) }
