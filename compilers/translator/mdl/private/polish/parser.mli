type token =
  | EOF
  | IDENT of (string)
  | DOT_IDENT of (string)
  | PARAM of (string)
  | DOT_OP of (string)
  | FLOAT of (string)
  | STRING of (string)
  | NOT_OP of (string)
  | HAT_OP of (string)
  | DOT_QUOTE_OP of (string)
  | DOT_HAT_OP of (string)
  | DOT_STAR_OP of (string)
  | DOT_SLASH_OP of (string)
  | DOT_BACKSLASH_OP of (string)
  | STAR_OP of (string)
  | SLASH_OP of (string)
  | BACKSLASH_OP of (string)
  | PERCENT_OP of (string)
  | PLUS_OP of (string)
  | DASH_OP of (string)
  | COMPARE_OP of (string)
  | BAR_BAR_OP of (string)
  | AMPER_AMPER_OP of (string)
  | QUOTE
  | COLON
  | COLON_EQUAL
  | COMMA
  | DOLLAR
  | DOT
  | SEMI
  | LPAREN
  | RPAREN
  | LBRACKET
  | RBRACKET
  | LBRACE
  | RBRACE
  | DOT_IF
  | DOT_THEN
  | DOT_ELSE
  | DOT_END
  | DOT_SWITCH
  | DOT_OTHERWISE
  | DOT_CASE
  | IF
  | THEN
  | ELSE
  | END

val file :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ast.expression
