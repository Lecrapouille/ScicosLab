%{
(***********************************************************************)
(*                                                                     *)
(*                        SciCos compiler                              *)
(*                                                                     *)
(*            Pierre Weis                                              *)
(*                                                                     *)
(*                               INRIA Rocquencourt                    *)
(*                                                                     *)
(*  Copyright 2009 INRIA                                               *)
(*  Distributed only by permission.                                    *)
(*                                                                     *)
(***********************************************************************)

(* $Id: parser.mly 4481 2011-09-16 16:01:33Z weis $ *)

open Ast;;

let mk_infix_application e1 op e2 = E_binary (op, e1, e2);;

let mk_unary_application op e1 = E_unary (op, e1);;

%}

%token EOF

%token <string> IDENT /* Lower case ident (e.g. x, cos, _1, or _xY) */
%token <string> PARAM /* Bloc parameter (e.g. u, u1, or u20) */

%token <string> DOT_OP

/* Basic constants */
%token <string> FLOAT

/* Arithmetic operators */
%token <string> TILDA_OP
%token <string> BANG_OP
%token <string> HAT_OP
%token <string> STAR_STAR_OP

%token <string> DOT_QUOTE_OP
%token <string> DOT_HAT_OP
%token <string> DOT_STAR_OP
%token <string> DOT_SLASH_OP
%token <string> DOT_BACKSLASH_OP

%token <string> STAR_OP
%token <string> SLASH_OP
%token <string> BACKSLASH_OP
%token <string> PERCENT_OP

%token <string> PLUS_OP
%token <string> DASH_OP

%token <string> LT_OP
%token <string> GT_OP
%token <string> EQ_OP
%token <string> NE_OP

%token <string> BAR_OP
%token <string> AMPER_OP

%token <string> BAR_BAR_OP
%token <string> AMPER_AMPER_OP

%token QUOTE
%token COLON
%token COLON_EQUAL
%token DOLLAR
%token COMMA
%token SEMI

/* Nested symbols */
%token LPAREN
%token RPAREN
%token LBRACKET
%token RBRACKET
%token LBRACE
%token RBRACE

/* Keywords */
%token IF
%token THEN
%token ELSE
%token FI

%token DOT_IF
%token DOT_THEN
%token DOT_ELSE
%token DOT_FI

/* Precedences and associativities. */

/* Binary operators. */

%nonassoc ELSE DOT_ELSE            /* (if ... then ... else ...) */

%right    BAR_BAR_OP               /* expr (e || e || e) */
%right    AMPER_AMPER_OP           /* expr (e && e && e) */

%right    BAR_OP                   /* expr (e | e | e) */
%right    AMPER_OP                 /* expr (e & e & e) */

%right    COLON_EQUAL               /* expr (e := e := e) */

%left     LT_OP GT_OP EQ_OP NE_OP

%left     SEMI
%left     COMMA

%right    COLON

%left     PLUS_OP DASH_OP
          /* expr (e OP e OP OP e) with OP starting with '+', or '-' */

%left     STAR_OP SLASH_OP BACKSLASH_OP PERCENT_OP
          /* expr (e OP e OP e) with OP starting with '*', or '/' */

%nonassoc prec_unary_minus
          /* unary DASH_OP e.g. DASH_OP is '-' */

%left     DOT_STAR_OP DOT_SLASH_OP DOT_BACKSLASH_OP

%right    DOT_HAT_OP HAT_OP STAR_STAR_OP prec_star_star

%right    BANG_OP TILDA_OP
          /* expr (! e) */

%left     DOT_OP
%nonassoc QUOTE DOT_QUOTE_OP

/* Predefined precedences to resolve conflicts. */

%nonassoc below_RPAREN
%nonassoc RPAREN
%nonassoc LPAREN
%nonassoc RBRACKET
%nonassoc LBRACKET
%nonassoc RBRACE
%nonassoc LBRACE

%start file
%type <Ast.command list> file
%%

file:
  | commands EOF { $1 }
;

expr:
  | FLOAT
    { E_number $1 }
  | IDENT
    { E_variable $1 }
  | DOLLAR
    { E_dollar }
  | COLON
    { E_colon }
  | PARAM
    { E_parameter $1 }
  | expr LBRACKET expr_comma_list RBRACKET
    { E_apply ($1, $3) }
  | expr LPAREN expr_comma_list RPAREN
    { E_apply ($1, $3) }
  | DOT_IF expr DOT_THEN expr DOT_ELSE expr DOT_FI
    { E_if ($2, $4, $6) }

  /* Binary operators */

  | expr BAR_BAR_OP expr
    { mk_infix_application $1 $2 $3 }
  | expr AMPER_AMPER_OP expr
    { mk_infix_application $1 $2 $3 }

    | expr COLON_EQUAL expr
      { mk_infix_application $1 ":=" $3 }

    | expr EQ_OP expr
      { mk_infix_application $1 $2 $3 }
    | expr LT_OP expr
      { mk_infix_application $1 $2 $3 }
    | expr GT_OP expr
      { mk_infix_application $1 $2 $3 }
    | expr NE_OP expr
      { mk_infix_application $1 $2 $3 }

  | expr PLUS_OP expr
    { mk_infix_application $1 $2 $3 }
    | expr DASH_OP expr
      { mk_infix_application $1 $2 $3 }
  | expr STAR_OP expr
    { mk_infix_application $1 $2 $3 }
    | expr SLASH_OP expr
      { mk_infix_application $1 $2 $3 }
    | expr BACKSLASH_OP expr
      { mk_infix_application $1 $2 $3 }
    | expr PERCENT_OP expr
      { mk_infix_application $1 $2 $3 }
  | expr HAT_OP expr
    { mk_infix_application $1 $2 $3 }
  | expr STAR_STAR_OP expr
    { mk_infix_application $1 $2 $3 }
  | expr DOT_OP label
    { E_record_access ($1, $3) }
  | expr DOT_SLASH_OP expr
    { mk_infix_application $1 $2 $3 }
  | expr DOT_STAR_OP expr
    { mk_infix_application $1 $2 $3 }
  | expr DOT_BACKSLASH_OP expr
    { mk_infix_application $1 $2 $3 }
  | expr DOT_HAT_OP expr
    { mk_infix_application $1 $2 $3 }

  /* Unary operators. */
  | DASH_OP expr %prec prec_unary_minus
    { mk_unary_application $1 $2 }
  | PLUS_OP expr %prec prec_unary_minus
    { mk_unary_application $1 $2 }
  | BANG_OP expr %prec prec_unary_minus
    { mk_unary_application $1 $2 }
  | TILDA_OP expr %prec prec_unary_minus
    { mk_unary_application $1 $2 }

  | expr DOT_QUOTE_OP
    { mk_unary_application $2 $1 }
  | expr QUOTE
    { mk_unary_application "\'" $1 }

  | expr COLON expr
    { mk_infix_application $1 ":" $3 }

  | LPAREN expr RPAREN
    { E_paren $2 }

  | LBRACKET RBRACKET
    { E_bracket (E_matrix []) }

  | LBRACKET concat RBRACKET
    { E_bracket $2 }
;

concat:
  | expr { $1 }
  | concat SEMI concat
    { mk_infix_application $1 ";" $3 }
  | concat COMMA concat
    { mk_infix_application $1 "," $3 }
;

label:
  | IDENT { $1 }
;

expr_comma_list:
  | { [ ] }
  | expr_comma_list1 { $1 }
;

expr_comma_list1:
  | expr { [ $1 ] }
  | expr COMMA expr_comma_list1 { $1 :: $3 }
;

command:
  | IF expr THEN command ELSE command FI
    { C_if ($2, $4, $6) }
  | LPAREN command RPAREN
    { C_paren $2 }
;

commands:
  | { [] }
  | command SEMI commands { $1 :: $3 }
;
