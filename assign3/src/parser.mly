%{
  open Ast.Lang
  exception Unimplemented
%}

%token <string> VAR
%token EOF
%token ARROW
%token DOT
%token FN
%token TFN
%token AS
%token STAR
%token LET
%token EQUAL
%token PLUS
%token SUB
%token MUL
%token DIV
%token BAR
%token WILDCARD
%token LBRACE
%token RBRACE
%token LPAREN
%token RPAREN
%token LBRACKET
%token RBRACKET
%token INJECT
%token IN
%token COLON
%token COMMA
%token MATCH
%token FORALL
%token EXISTS
%token TY_INT
%token <int> INT

%token LEFT
%token RIGHT

%left PLUS SUB
%left MUL DIV
%right ARROW

%start <Ast.Lang.Term.t> main

%%

main:
| e = term EOF { e }

term:
| n = INT { Term.Int(n) }
| v = VAR { Term.Var(v) }
| e1 = term b = binop e2 = term { Term.Binop(b, e1, e2) }
| FN LPAREN v = VAR COLON t = ty RPAREN DOT e = term { Term.Lam(v, t, e) }
| e1 = term e2 = term { Term.App(e1, e2) }
| LPAREN e1 = term COMMA e2 = term RPAREN { Term.Tuple(e1, e2) }
| INJECT e = term EQUAL d = dir AS t = ty { Term.Inject(e, d, t) }
| LET p = pat EQUAL e1 = term IN e2 = term { Term.Let(p, e1, e2) }
| MATCH e = term LBRACE m1 = match_part BAR m2 = match_part RBRACE { Term.Match(e, m1, m2) }
| TFN v = VAR DOT e = term { Term.TLam(v, e) }
| e = term LBRACKET t = ty RBRACKET { Term.TApp(e, t) }
| LBRACE t1 = ty COMMA e = term RBRACE AS t2 = ty { Term.TPack(t1, e, t2) }
| LPAREN e = term RPAREN { e }

match_part:
| LPAREN p = pat RPAREN ARROW e = term { (p, e) }

ty:
| v = VAR { Type.Var(v) }
| TY_INT { Type.Int }
| t1 = ty STAR t2 = ty { Type.Product(t1, t2) }
| t1 = ty PLUS t2 = ty { Type.Sum(t1, t2) }
| t1 = ty ARROW t2 = ty { Type.Fn(t1, t2) }
| FORALL v = VAR DOT t = ty { Type.ForAll(v, t) }
| EXISTS v = VAR DOT t = ty { Type.Exists(v, t) }
| LPAREN t = ty RPAREN { t }

pat:
| WILDCARD { Pattern.Wildcard }
| v = VAR COLON t = ty { Pattern.Var(v, t) }
| p = pat AS v = VAR COLON t = ty { Pattern.Alias(p, v, t) }
| LPAREN p1 = pat COMMA p2 = pat  RPAREN { Pattern.Tuple(p1, p2) }
| LBRACE v1 = VAR COMMA v2 = VAR RBRACE { Pattern.TUnpack(v1, v2) }
| LPAREN p = pat RPAREN { p }

dir:
| LEFT {Ast.Left}
| RIGHT {Ast.Right}

%inline binop:
| PLUS { Ast.Add }
| SUB { Ast.Sub }
| STAR { Ast.Mul }
| DIV { Ast.Div }
