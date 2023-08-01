type token =
  | IDENT of (string)
  | UNSIGNED_INTEGER of (string)
  | UNSIGNED_NUMBER of (string)
  | STRING of (string)
  | ALGORITHM
  | AND
  | ANNOTATION
  | ASSERT
  | BLOCK
  | CLASS
  | CONNECT
  | CONNECTOR
  | CONSTANT
  | DISCRETE
  | EACH
  | ELSE
  | ELSEIF
  | ELSEWHEN
  | ENCAPSULATED
  | END
  | ENUMERATION
  | EQUATION
  | EXTENDS
  | EXTERNAL
  | FALSE
  | FINAL
  | FLOW
  | FOR
  | FUNCTION
  | IF
  | IMPORT
  | IN
  | INITIAL
  | INNER
  | INPUT
  | LOOP
  | MODEL
  | NOT
  | OR
  | OUTER
  | OUTPUT
  | PACKAGE
  | PARAMETER
  | PARTIAL
  | PROTECTED
  | PUBLIC
  | RECORD
  | REDECLARE
  | REPLACEABLE
  | TERMINATE
  | THEN
  | TRUE
  | TYPE
  | WHEN
  | WHILE
  | WITHIN
  | LP
  | RP
  | LSB
  | RSB
  | LCB
  | RCB
  | DOT
  | CM
  | SC
  | CL
  | PLUS
  | MINUS
  | STAR
  | SLASH
  | EXP
  | EQ
  | COLEQ
  | LT
  | GT
  | LE
  | GE
  | EE
  | NE
  | EOF

val stored_definition_eof :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> ParseTree.t
