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

open Parsing;;
# 2 "parser.mly"
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

(* $Id: parser.ml 4481 2011-09-16 16:01:33Z weis $ *)

open Ast;;

let mk_infix_application e1 op e2 = E_binary (op, e1, e2);;

let mk_unary_application op e1 = E_unary (op, e1);;

let cons1 x (y, l) = x, y :: l;;

let mk_switch s cases =
  let default, cases =
    match List.rev cases with
    | ([], default) :: cases -> default, List.rev cases
    | _ -> assert false in
  E_switch {
    switch_subject = s;
    switch_cases = cases;
    switch_default = default;
  }
;;
# 87 "parser.ml"
let yytransl_const = [|
    0 (* EOF *);
  279 (* QUOTE *);
  280 (* COLON *);
  281 (* COLON_EQUAL *);
  282 (* COMMA *);
  283 (* DOLLAR *);
  284 (* DOT *);
  285 (* SEMI *);
  286 (* LPAREN *);
  287 (* RPAREN *);
  288 (* LBRACKET *);
  289 (* RBRACKET *);
  290 (* LBRACE *);
  291 (* RBRACE *);
  292 (* DOT_IF *);
  293 (* DOT_THEN *);
  294 (* DOT_ELSE *);
  295 (* DOT_END *);
  296 (* DOT_SWITCH *);
  297 (* DOT_OTHERWISE *);
  298 (* DOT_CASE *);
  299 (* IF *);
  300 (* THEN *);
  301 (* ELSE *);
  302 (* END *);
    0|]

let yytransl_block = [|
  257 (* IDENT *);
  258 (* DOT_IDENT *);
  259 (* PARAM *);
  260 (* DOT_OP *);
  261 (* FLOAT *);
  262 (* STRING *);
  263 (* NOT_OP *);
  264 (* HAT_OP *);
  265 (* DOT_QUOTE_OP *);
  266 (* DOT_HAT_OP *);
  267 (* DOT_STAR_OP *);
  268 (* DOT_SLASH_OP *);
  269 (* DOT_BACKSLASH_OP *);
  270 (* STAR_OP *);
  271 (* SLASH_OP *);
  272 (* BACKSLASH_OP *);
  273 (* PERCENT_OP *);
  274 (* PLUS_OP *);
  275 (* DASH_OP *);
  276 (* COMPARE_OP *);
  277 (* BAR_BAR_OP *);
  278 (* AMPER_AMPER_OP *);
    0|]

let yylhs = "\255\255\
\001\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
\002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
\002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
\002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
\002\000\002\000\002\000\002\000\005\000\005\000\005\000\003\000\
\003\000\006\000\006\000\004\000\004\000\008\000\008\000\007\000\
\000\000"

let yylen = "\002\000\
\002\000\001\000\001\000\001\000\001\000\001\000\001\000\004\000\
\004\000\007\000\003\000\003\000\003\000\003\000\003\000\003\000\
\003\000\003\000\003\000\003\000\003\000\003\000\003\000\002\000\
\003\000\003\000\003\000\003\000\002\000\002\000\002\000\002\000\
\002\000\003\000\003\000\003\000\000\000\001\000\003\000\000\000\
\001\000\001\000\003\000\003\000\002\000\001\000\003\000\004\000\
\002\000"

let yydefred = "\000\000\
\000\000\000\000\004\000\007\000\002\000\003\000\000\000\000\000\
\000\000\006\000\005\000\000\000\000\000\000\000\000\000\049\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\001\000\024\000\000\000\000\000\032\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\033\000\000\000\000\000\000\000\
\000\000\035\000\000\000\036\000\000\000\000\000\000\000\000\000\
\011\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\041\000\000\000\043\000\039\000\
\000\000\000\000\000\000\000\000\000\000\045\000\009\000\008\000\
\000\000\044\000\000\000\000\000\000\000\047\000\000\000\010\000"

let yydgoto = "\002\000\
\016\000\022\000\076\000\057\000\023\000\024\000\058\000\085\000"

let yysindex = "\004\000\
\132\255\000\000\000\000\000\000\000\000\000\000\132\255\132\255\
\132\255\000\000\000\000\132\255\132\255\132\255\132\255\000\000\
\092\002\089\003\089\003\089\003\179\002\204\002\242\254\250\254\
\148\002\058\255\000\000\000\000\132\255\132\255\000\000\132\255\
\132\255\132\255\132\255\132\255\132\255\132\255\132\255\132\255\
\132\255\132\255\132\255\132\255\000\000\132\255\132\255\132\255\
\132\255\000\000\132\255\000\000\132\255\132\255\132\255\100\255\
\000\000\009\255\251\254\254\254\254\254\254\254\254\254\254\254\
\089\003\089\003\089\003\089\003\073\003\073\003\048\003\229\002\
\254\002\048\003\023\003\023\255\000\000\252\254\000\000\000\000\
\117\002\183\255\132\255\229\002\029\255\000\000\000\000\000\000\
\132\255\000\000\024\255\132\255\219\255\000\000\229\002\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\028\255\000\000\000\000\000\000\
\000\000\190\000\219\000\248\000\000\000\247\254\000\000\030\255\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\033\255\
\051\255\000\000\000\000\000\000\028\255\000\000\000\000\000\000\
\000\000\000\000\001\000\033\000\065\000\097\000\129\000\161\000\
\024\001\056\001\088\001\120\001\152\001\184\001\213\001\051\002\
\037\002\242\001\015\002\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\059\255\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\011\255\000\000"

let yygindex = "\000\000\
\000\000\002\000\037\000\029\000\036\000\220\255\000\000\000\000"

let yytablesize = 1145
let yytable = "\028\000\
\023\000\029\000\017\000\031\000\001\000\030\000\031\000\032\000\
\018\000\019\000\020\000\077\000\077\000\021\000\079\000\025\000\
\026\000\045\000\052\000\042\000\045\000\042\000\053\000\042\000\
\048\000\042\000\049\000\048\000\088\000\049\000\059\000\060\000\
\022\000\061\000\062\000\063\000\064\000\065\000\066\000\067\000\
\068\000\069\000\070\000\071\000\072\000\073\000\091\000\074\000\
\075\000\055\000\056\000\048\000\048\000\087\000\092\000\081\000\
\082\000\084\000\094\000\028\000\037\000\029\000\038\000\040\000\
\028\000\030\000\031\000\032\000\033\000\034\000\035\000\036\000\
\037\000\038\000\039\000\040\000\041\000\042\000\043\000\044\000\
\045\000\046\000\047\000\040\000\046\000\078\000\086\000\048\000\
\080\000\049\000\093\000\000\000\000\000\095\000\000\000\000\000\
\026\000\000\000\055\000\056\000\003\000\000\000\004\000\000\000\
\005\000\006\000\007\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\008\000\009\000\000\000\
\000\000\000\000\000\000\010\000\000\000\000\000\011\000\000\000\
\025\000\012\000\000\000\013\000\003\000\083\000\004\000\014\000\
\005\000\006\000\007\000\015\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\008\000\009\000\000\000\
\000\000\000\000\000\000\010\000\000\000\000\000\011\000\000\000\
\027\000\012\000\000\000\013\000\000\000\000\000\000\000\014\000\
\000\000\000\000\000\000\015\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\028\000\000\000\029\000\000\000\000\000\031\000\030\000\031\000\
\032\000\033\000\034\000\035\000\036\000\037\000\038\000\039\000\
\040\000\041\000\042\000\043\000\044\000\045\000\046\000\047\000\
\000\000\000\000\000\000\000\000\048\000\000\000\049\000\000\000\
\000\000\000\000\030\000\000\000\028\000\090\000\029\000\000\000\
\000\000\000\000\030\000\031\000\032\000\033\000\034\000\035\000\
\036\000\037\000\038\000\039\000\040\000\041\000\042\000\043\000\
\044\000\045\000\046\000\047\000\000\000\000\000\000\000\029\000\
\048\000\000\000\049\000\000\000\000\000\000\000\000\000\000\000\
\000\000\096\000\023\000\000\000\023\000\000\000\000\000\000\000\
\023\000\000\000\023\000\023\000\023\000\023\000\023\000\023\000\
\023\000\023\000\023\000\023\000\023\000\023\000\023\000\018\000\
\023\000\023\000\023\000\000\000\000\000\023\000\000\000\023\000\
\000\000\023\000\000\000\023\000\000\000\023\000\023\000\023\000\
\000\000\023\000\023\000\022\000\022\000\022\000\022\000\022\000\
\022\000\022\000\022\000\022\000\022\000\022\000\022\000\019\000\
\022\000\022\000\022\000\000\000\000\000\022\000\000\000\022\000\
\000\000\022\000\000\000\022\000\000\000\022\000\022\000\022\000\
\000\000\022\000\022\000\028\000\028\000\028\000\028\000\028\000\
\028\000\028\000\028\000\028\000\028\000\028\000\028\000\020\000\
\028\000\028\000\028\000\000\000\000\000\028\000\000\000\028\000\
\000\000\028\000\000\000\028\000\000\000\028\000\028\000\028\000\
\000\000\028\000\028\000\026\000\026\000\026\000\026\000\026\000\
\026\000\026\000\026\000\026\000\026\000\026\000\026\000\021\000\
\026\000\026\000\026\000\000\000\000\000\026\000\000\000\026\000\
\000\000\026\000\000\000\026\000\000\000\026\000\026\000\026\000\
\000\000\026\000\026\000\025\000\025\000\025\000\025\000\025\000\
\025\000\025\000\025\000\025\000\025\000\025\000\025\000\016\000\
\025\000\025\000\025\000\000\000\000\000\025\000\000\000\025\000\
\000\000\025\000\000\000\025\000\000\000\025\000\025\000\025\000\
\000\000\025\000\025\000\027\000\027\000\027\000\027\000\027\000\
\027\000\027\000\027\000\027\000\027\000\027\000\027\000\017\000\
\027\000\027\000\027\000\000\000\000\000\027\000\000\000\027\000\
\000\000\027\000\000\000\027\000\000\000\027\000\027\000\027\000\
\000\000\027\000\027\000\031\000\031\000\031\000\031\000\031\000\
\031\000\031\000\031\000\031\000\015\000\031\000\031\000\031\000\
\000\000\000\000\031\000\000\000\031\000\000\000\031\000\000\000\
\031\000\000\000\031\000\031\000\031\000\000\000\031\000\031\000\
\030\000\030\000\030\000\030\000\030\000\030\000\030\000\030\000\
\030\000\034\000\030\000\030\000\030\000\000\000\000\000\030\000\
\000\000\030\000\000\000\030\000\000\000\030\000\000\000\030\000\
\030\000\030\000\000\000\030\000\030\000\029\000\029\000\029\000\
\029\000\029\000\029\000\029\000\029\000\029\000\014\000\029\000\
\029\000\029\000\000\000\000\000\029\000\000\000\029\000\000\000\
\029\000\000\000\029\000\000\000\029\000\029\000\029\000\000\000\
\029\000\029\000\000\000\000\000\013\000\018\000\018\000\018\000\
\018\000\018\000\018\000\018\000\018\000\018\000\000\000\018\000\
\018\000\018\000\012\000\000\000\018\000\000\000\018\000\000\000\
\018\000\000\000\018\000\000\000\018\000\018\000\018\000\000\000\
\018\000\018\000\000\000\000\000\000\000\019\000\019\000\019\000\
\019\000\019\000\019\000\019\000\019\000\019\000\000\000\019\000\
\019\000\019\000\000\000\000\000\019\000\000\000\019\000\000\000\
\019\000\000\000\019\000\027\000\019\000\019\000\019\000\000\000\
\019\000\019\000\000\000\000\000\000\000\020\000\020\000\020\000\
\020\000\020\000\020\000\020\000\020\000\020\000\000\000\020\000\
\020\000\020\000\000\000\000\000\020\000\000\000\020\000\000\000\
\020\000\000\000\020\000\000\000\020\000\020\000\020\000\000\000\
\020\000\020\000\000\000\000\000\000\000\021\000\021\000\021\000\
\021\000\021\000\021\000\021\000\021\000\021\000\000\000\021\000\
\021\000\021\000\000\000\000\000\021\000\000\000\021\000\000\000\
\021\000\000\000\021\000\000\000\021\000\021\000\021\000\000\000\
\021\000\021\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\016\000\016\000\016\000\016\000\016\000\000\000\016\000\
\016\000\016\000\000\000\000\000\016\000\000\000\016\000\000\000\
\016\000\000\000\016\000\000\000\016\000\016\000\016\000\000\000\
\016\000\016\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\017\000\017\000\017\000\017\000\017\000\000\000\017\000\
\017\000\017\000\000\000\000\000\017\000\000\000\017\000\000\000\
\017\000\000\000\017\000\000\000\017\000\017\000\017\000\000\000\
\017\000\017\000\000\000\000\000\000\000\000\000\000\000\000\000\
\015\000\015\000\015\000\000\000\000\000\015\000\015\000\000\000\
\000\000\015\000\000\000\015\000\000\000\015\000\000\000\015\000\
\000\000\015\000\015\000\015\000\000\000\015\000\015\000\000\000\
\000\000\000\000\000\000\000\000\000\000\034\000\034\000\034\000\
\000\000\000\000\034\000\034\000\000\000\000\000\034\000\000\000\
\034\000\000\000\034\000\000\000\034\000\000\000\034\000\034\000\
\034\000\000\000\034\000\034\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\014\000\014\000\000\000\000\000\000\000\
\014\000\000\000\000\000\014\000\000\000\014\000\000\000\014\000\
\000\000\014\000\000\000\014\000\014\000\014\000\000\000\014\000\
\014\000\013\000\000\000\000\000\000\000\000\000\013\000\000\000\
\000\000\013\000\000\000\013\000\000\000\013\000\000\000\013\000\
\000\000\013\000\013\000\013\000\012\000\013\000\013\000\012\000\
\000\000\012\000\000\000\012\000\000\000\012\000\000\000\012\000\
\012\000\012\000\000\000\012\000\012\000\028\000\000\000\029\000\
\000\000\000\000\000\000\030\000\031\000\032\000\033\000\034\000\
\035\000\036\000\037\000\038\000\039\000\040\000\041\000\042\000\
\043\000\044\000\045\000\046\000\047\000\000\000\028\000\000\000\
\029\000\048\000\000\000\049\000\030\000\031\000\032\000\033\000\
\034\000\035\000\036\000\037\000\038\000\039\000\040\000\041\000\
\042\000\043\000\044\000\045\000\046\000\047\000\000\000\000\000\
\000\000\000\000\048\000\000\000\049\000\028\000\000\000\029\000\
\000\000\000\000\089\000\030\000\031\000\032\000\033\000\034\000\
\035\000\036\000\037\000\038\000\039\000\040\000\041\000\042\000\
\043\000\044\000\045\000\046\000\047\000\000\000\000\000\000\000\
\000\000\048\000\000\000\049\000\028\000\000\000\029\000\000\000\
\054\000\000\000\030\000\031\000\032\000\033\000\034\000\035\000\
\036\000\037\000\038\000\039\000\040\000\041\000\042\000\043\000\
\044\000\045\000\046\000\047\000\000\000\028\000\000\000\029\000\
\048\000\050\000\049\000\030\000\031\000\032\000\033\000\034\000\
\035\000\036\000\037\000\038\000\039\000\040\000\041\000\042\000\
\043\000\044\000\045\000\046\000\047\000\051\000\028\000\000\000\
\029\000\048\000\000\000\049\000\030\000\031\000\032\000\033\000\
\034\000\035\000\036\000\037\000\038\000\039\000\040\000\041\000\
\042\000\043\000\044\000\045\000\046\000\047\000\000\000\028\000\
\000\000\029\000\048\000\000\000\049\000\030\000\031\000\032\000\
\033\000\034\000\035\000\036\000\037\000\038\000\039\000\040\000\
\041\000\042\000\000\000\044\000\045\000\046\000\047\000\000\000\
\028\000\000\000\029\000\048\000\000\000\049\000\030\000\031\000\
\032\000\033\000\034\000\035\000\036\000\037\000\038\000\039\000\
\040\000\041\000\042\000\000\000\000\000\045\000\046\000\047\000\
\000\000\028\000\000\000\029\000\048\000\000\000\049\000\030\000\
\031\000\032\000\033\000\034\000\035\000\036\000\037\000\038\000\
\039\000\040\000\041\000\000\000\000\000\000\000\045\000\046\000\
\000\000\000\000\028\000\000\000\029\000\048\000\000\000\049\000\
\030\000\031\000\032\000\033\000\034\000\035\000\036\000\037\000\
\038\000\039\000\028\000\000\000\029\000\000\000\000\000\045\000\
\030\000\031\000\032\000\033\000\034\000\035\000\048\000\000\000\
\049\000\000\000\000\000\000\000\000\000\000\000\000\000\045\000\
\000\000\000\000\000\000\000\000\000\000\000\000\048\000\000\000\
\049\000"

let yycheck = "\002\001\
\000\000\004\001\001\000\009\001\001\000\008\001\009\001\010\001\
\007\000\008\000\009\000\048\000\049\000\012\000\051\000\014\000\
\015\000\023\001\033\001\029\001\023\001\031\001\029\001\033\001\
\030\001\035\001\032\001\030\001\033\001\032\001\029\000\030\000\
\000\000\032\000\033\000\034\000\035\000\036\000\037\000\038\000\
\039\000\040\000\041\000\042\000\043\000\044\000\083\000\046\000\
\047\000\041\001\042\001\041\001\042\001\031\001\026\001\054\000\
\055\000\056\000\035\001\002\001\033\001\004\001\033\001\031\001\
\000\000\008\001\009\001\010\001\011\001\012\001\013\001\014\001\
\015\001\016\001\017\001\018\001\019\001\020\001\021\001\022\001\
\023\001\024\001\025\001\033\001\026\001\049\000\058\000\030\001\
\053\000\032\001\089\000\255\255\255\255\092\000\255\255\255\255\
\000\000\255\255\041\001\042\001\001\001\255\255\003\001\255\255\
\005\001\006\001\007\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\018\001\019\001\255\255\
\255\255\255\255\255\255\024\001\255\255\255\255\027\001\255\255\
\000\000\030\001\255\255\032\001\001\001\034\001\003\001\036\001\
\005\001\006\001\007\001\040\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\018\001\019\001\255\255\
\255\255\255\255\255\255\024\001\255\255\255\255\027\001\255\255\
\000\000\030\001\255\255\032\001\255\255\255\255\255\255\036\001\
\255\255\255\255\255\255\040\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\002\001\255\255\004\001\255\255\255\255\000\000\008\001\009\001\
\010\001\011\001\012\001\013\001\014\001\015\001\016\001\017\001\
\018\001\019\001\020\001\021\001\022\001\023\001\024\001\025\001\
\255\255\255\255\255\255\255\255\030\001\255\255\032\001\255\255\
\255\255\255\255\000\000\255\255\002\001\039\001\004\001\255\255\
\255\255\255\255\008\001\009\001\010\001\011\001\012\001\013\001\
\014\001\015\001\016\001\017\001\018\001\019\001\020\001\021\001\
\022\001\023\001\024\001\025\001\255\255\255\255\255\255\000\000\
\030\001\255\255\032\001\255\255\255\255\255\255\255\255\255\255\
\255\255\039\001\002\001\255\255\004\001\255\255\255\255\255\255\
\008\001\255\255\010\001\011\001\012\001\013\001\014\001\015\001\
\016\001\017\001\018\001\019\001\020\001\021\001\022\001\000\000\
\024\001\025\001\026\001\255\255\255\255\029\001\255\255\031\001\
\255\255\033\001\255\255\035\001\255\255\037\001\038\001\039\001\
\255\255\041\001\042\001\011\001\012\001\013\001\014\001\015\001\
\016\001\017\001\018\001\019\001\020\001\021\001\022\001\000\000\
\024\001\025\001\026\001\255\255\255\255\029\001\255\255\031\001\
\255\255\033\001\255\255\035\001\255\255\037\001\038\001\039\001\
\255\255\041\001\042\001\011\001\012\001\013\001\014\001\015\001\
\016\001\017\001\018\001\019\001\020\001\021\001\022\001\000\000\
\024\001\025\001\026\001\255\255\255\255\029\001\255\255\031\001\
\255\255\033\001\255\255\035\001\255\255\037\001\038\001\039\001\
\255\255\041\001\042\001\011\001\012\001\013\001\014\001\015\001\
\016\001\017\001\018\001\019\001\020\001\021\001\022\001\000\000\
\024\001\025\001\026\001\255\255\255\255\029\001\255\255\031\001\
\255\255\033\001\255\255\035\001\255\255\037\001\038\001\039\001\
\255\255\041\001\042\001\011\001\012\001\013\001\014\001\015\001\
\016\001\017\001\018\001\019\001\020\001\021\001\022\001\000\000\
\024\001\025\001\026\001\255\255\255\255\029\001\255\255\031\001\
\255\255\033\001\255\255\035\001\255\255\037\001\038\001\039\001\
\255\255\041\001\042\001\011\001\012\001\013\001\014\001\015\001\
\016\001\017\001\018\001\019\001\020\001\021\001\022\001\000\000\
\024\001\025\001\026\001\255\255\255\255\029\001\255\255\031\001\
\255\255\033\001\255\255\035\001\255\255\037\001\038\001\039\001\
\255\255\041\001\042\001\014\001\015\001\016\001\017\001\018\001\
\019\001\020\001\021\001\022\001\000\000\024\001\025\001\026\001\
\255\255\255\255\029\001\255\255\031\001\255\255\033\001\255\255\
\035\001\255\255\037\001\038\001\039\001\255\255\041\001\042\001\
\014\001\015\001\016\001\017\001\018\001\019\001\020\001\021\001\
\022\001\000\000\024\001\025\001\026\001\255\255\255\255\029\001\
\255\255\031\001\255\255\033\001\255\255\035\001\255\255\037\001\
\038\001\039\001\255\255\041\001\042\001\014\001\015\001\016\001\
\017\001\018\001\019\001\020\001\021\001\022\001\000\000\024\001\
\025\001\026\001\255\255\255\255\029\001\255\255\031\001\255\255\
\033\001\255\255\035\001\255\255\037\001\038\001\039\001\255\255\
\041\001\042\001\255\255\255\255\000\000\014\001\015\001\016\001\
\017\001\018\001\019\001\020\001\021\001\022\001\255\255\024\001\
\025\001\026\001\000\000\255\255\029\001\255\255\031\001\255\255\
\033\001\255\255\035\001\255\255\037\001\038\001\039\001\255\255\
\041\001\042\001\255\255\255\255\255\255\014\001\015\001\016\001\
\017\001\018\001\019\001\020\001\021\001\022\001\255\255\024\001\
\025\001\026\001\255\255\255\255\029\001\255\255\031\001\255\255\
\033\001\255\255\035\001\000\000\037\001\038\001\039\001\255\255\
\041\001\042\001\255\255\255\255\255\255\014\001\015\001\016\001\
\017\001\018\001\019\001\020\001\021\001\022\001\255\255\024\001\
\025\001\026\001\255\255\255\255\029\001\255\255\031\001\255\255\
\033\001\255\255\035\001\255\255\037\001\038\001\039\001\255\255\
\041\001\042\001\255\255\255\255\255\255\014\001\015\001\016\001\
\017\001\018\001\019\001\020\001\021\001\022\001\255\255\024\001\
\025\001\026\001\255\255\255\255\029\001\255\255\031\001\255\255\
\033\001\255\255\035\001\255\255\037\001\038\001\039\001\255\255\
\041\001\042\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\018\001\019\001\020\001\021\001\022\001\255\255\024\001\
\025\001\026\001\255\255\255\255\029\001\255\255\031\001\255\255\
\033\001\255\255\035\001\255\255\037\001\038\001\039\001\255\255\
\041\001\042\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\018\001\019\001\020\001\021\001\022\001\255\255\024\001\
\025\001\026\001\255\255\255\255\029\001\255\255\031\001\255\255\
\033\001\255\255\035\001\255\255\037\001\038\001\039\001\255\255\
\041\001\042\001\255\255\255\255\255\255\255\255\255\255\255\255\
\020\001\021\001\022\001\255\255\255\255\025\001\026\001\255\255\
\255\255\029\001\255\255\031\001\255\255\033\001\255\255\035\001\
\255\255\037\001\038\001\039\001\255\255\041\001\042\001\255\255\
\255\255\255\255\255\255\255\255\255\255\020\001\021\001\022\001\
\255\255\255\255\025\001\026\001\255\255\255\255\029\001\255\255\
\031\001\255\255\033\001\255\255\035\001\255\255\037\001\038\001\
\039\001\255\255\041\001\042\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\021\001\022\001\255\255\255\255\255\255\
\026\001\255\255\255\255\029\001\255\255\031\001\255\255\033\001\
\255\255\035\001\255\255\037\001\038\001\039\001\255\255\041\001\
\042\001\021\001\255\255\255\255\255\255\255\255\026\001\255\255\
\255\255\029\001\255\255\031\001\255\255\033\001\255\255\035\001\
\255\255\037\001\038\001\039\001\026\001\041\001\042\001\029\001\
\255\255\031\001\255\255\033\001\255\255\035\001\255\255\037\001\
\038\001\039\001\255\255\041\001\042\001\002\001\255\255\004\001\
\255\255\255\255\255\255\008\001\009\001\010\001\011\001\012\001\
\013\001\014\001\015\001\016\001\017\001\018\001\019\001\020\001\
\021\001\022\001\023\001\024\001\025\001\255\255\002\001\255\255\
\004\001\030\001\255\255\032\001\008\001\009\001\010\001\011\001\
\012\001\013\001\014\001\015\001\016\001\017\001\018\001\019\001\
\020\001\021\001\022\001\023\001\024\001\025\001\255\255\255\255\
\255\255\255\255\030\001\255\255\032\001\002\001\255\255\004\001\
\255\255\255\255\038\001\008\001\009\001\010\001\011\001\012\001\
\013\001\014\001\015\001\016\001\017\001\018\001\019\001\020\001\
\021\001\022\001\023\001\024\001\025\001\255\255\255\255\255\255\
\255\255\030\001\255\255\032\001\002\001\255\255\004\001\255\255\
\037\001\255\255\008\001\009\001\010\001\011\001\012\001\013\001\
\014\001\015\001\016\001\017\001\018\001\019\001\020\001\021\001\
\022\001\023\001\024\001\025\001\255\255\002\001\255\255\004\001\
\030\001\031\001\032\001\008\001\009\001\010\001\011\001\012\001\
\013\001\014\001\015\001\016\001\017\001\018\001\019\001\020\001\
\021\001\022\001\023\001\024\001\025\001\026\001\002\001\255\255\
\004\001\030\001\255\255\032\001\008\001\009\001\010\001\011\001\
\012\001\013\001\014\001\015\001\016\001\017\001\018\001\019\001\
\020\001\021\001\022\001\023\001\024\001\025\001\255\255\002\001\
\255\255\004\001\030\001\255\255\032\001\008\001\009\001\010\001\
\011\001\012\001\013\001\014\001\015\001\016\001\017\001\018\001\
\019\001\020\001\255\255\022\001\023\001\024\001\025\001\255\255\
\002\001\255\255\004\001\030\001\255\255\032\001\008\001\009\001\
\010\001\011\001\012\001\013\001\014\001\015\001\016\001\017\001\
\018\001\019\001\020\001\255\255\255\255\023\001\024\001\025\001\
\255\255\002\001\255\255\004\001\030\001\255\255\032\001\008\001\
\009\001\010\001\011\001\012\001\013\001\014\001\015\001\016\001\
\017\001\018\001\019\001\255\255\255\255\255\255\023\001\024\001\
\255\255\255\255\002\001\255\255\004\001\030\001\255\255\032\001\
\008\001\009\001\010\001\011\001\012\001\013\001\014\001\015\001\
\016\001\017\001\002\001\255\255\004\001\255\255\255\255\023\001\
\008\001\009\001\010\001\011\001\012\001\013\001\030\001\255\255\
\032\001\255\255\255\255\255\255\255\255\255\255\255\255\023\001\
\255\255\255\255\255\255\255\255\255\255\255\255\030\001\255\255\
\032\001"

let yynames_const = "\
  EOF\000\
  QUOTE\000\
  COLON\000\
  COLON_EQUAL\000\
  COMMA\000\
  DOLLAR\000\
  DOT\000\
  SEMI\000\
  LPAREN\000\
  RPAREN\000\
  LBRACKET\000\
  RBRACKET\000\
  LBRACE\000\
  RBRACE\000\
  DOT_IF\000\
  DOT_THEN\000\
  DOT_ELSE\000\
  DOT_END\000\
  DOT_SWITCH\000\
  DOT_OTHERWISE\000\
  DOT_CASE\000\
  IF\000\
  THEN\000\
  ELSE\000\
  END\000\
  "

let yynames_block = "\
  IDENT\000\
  DOT_IDENT\000\
  PARAM\000\
  DOT_OP\000\
  FLOAT\000\
  STRING\000\
  NOT_OP\000\
  HAT_OP\000\
  DOT_QUOTE_OP\000\
  DOT_HAT_OP\000\
  DOT_STAR_OP\000\
  DOT_SLASH_OP\000\
  DOT_BACKSLASH_OP\000\
  STAR_OP\000\
  SLASH_OP\000\
  BACKSLASH_OP\000\
  PERCENT_OP\000\
  PLUS_OP\000\
  DASH_OP\000\
  COMPARE_OP\000\
  BAR_BAR_OP\000\
  AMPER_AMPER_OP\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    Obj.repr(
# 160 "parser.mly"
             ( _1 )
# 560 "parser.ml"
               : Ast.expression))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 165 "parser.mly"
    ( E_number _1 )
# 567 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 167 "parser.mly"
    ( E_string _1 )
# 574 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 169 "parser.mly"
    ( E_variable _1 )
# 581 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    Obj.repr(
# 171 "parser.mly"
    ( E_dollar )
# 587 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    Obj.repr(
# 173 "parser.mly"
    ( E_colon )
# 593 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 175 "parser.mly"
    ( E_parameter _1 )
# 600 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'expr_comma_list) in
    Obj.repr(
# 177 "parser.mly"
    ( E_apply (_1, _3) )
# 608 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'expr_comma_list) in
    Obj.repr(
# 179 "parser.mly"
    ( E_apply (_1, _3) )
# 616 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 5 : 'expr) in
    let _4 = (Parsing.peek_val __caml_parser_env 3 : 'expr) in
    let _6 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    Obj.repr(
# 181 "parser.mly"
    ( E_if (_2, _4, _6) )
# 625 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'switch_cases) in
    Obj.repr(
# 184 "parser.mly"
    ( mk_switch _2 _3 )
# 633 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 189 "parser.mly"
    ( mk_infix_application _1 _2 _3 )
# 642 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 191 "parser.mly"
    ( mk_infix_application _1 _2 _3 )
# 651 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 194 "parser.mly"
      ( mk_infix_application _1 ":=" _3 )
# 659 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 197 "parser.mly"
      ( mk_infix_application _1 _2 _3 )
# 668 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 200 "parser.mly"
    ( mk_infix_application _1 _2 _3 )
# 677 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 202 "parser.mly"
      ( mk_infix_application _1 _2 _3 )
# 686 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 204 "parser.mly"
    ( mk_infix_application _1 _2 _3 )
# 695 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 206 "parser.mly"
      ( mk_infix_application _1 _2 _3 )
# 704 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 208 "parser.mly"
      ( mk_infix_application _1 _2 _3 )
# 713 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 210 "parser.mly"
      ( mk_infix_application _1 _2 _3 )
# 722 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 212 "parser.mly"
    ( mk_infix_application _1 _2 _3 )
# 731 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 214 "parser.mly"
    ( mk_infix_application _1 _2 _3 )
# 740 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 216 "parser.mly"
    ( E_record_access (_1, _2) )
# 748 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 218 "parser.mly"
    ( mk_infix_application _1 _2 _3 )
# 757 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 220 "parser.mly"
    ( mk_infix_application _1 _2 _3 )
# 766 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 222 "parser.mly"
    ( mk_infix_application _1 _2 _3 )
# 775 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 224 "parser.mly"
    ( mk_infix_application _1 _2 _3 )
# 784 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 228 "parser.mly"
    ( mk_unary_application _1 _2 )
# 792 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 230 "parser.mly"
    ( mk_unary_application _1 _2 )
# 800 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 232 "parser.mly"
    ( mk_unary_application _1 _2 )
# 808 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 235 "parser.mly"
    ( mk_unary_application _2 _1 )
# 816 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    Obj.repr(
# 237 "parser.mly"
    ( mk_unary_application "\'" _1 )
# 823 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 240 "parser.mly"
    ( mk_infix_application _1 ":" _3 )
# 831 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    Obj.repr(
# 243 "parser.mly"
    ( E_paren _2 )
# 838 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'concat) in
    Obj.repr(
# 246 "parser.mly"
    ( E_bracket (E_matrix _2) )
# 845 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    Obj.repr(
# 250 "parser.mly"
    ( [] )
# 851 "parser.ml"
               : 'concat))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'expr_comma_list1) in
    Obj.repr(
# 252 "parser.mly"
    ( [ _1 ] )
# 858 "parser.ml"
               : 'concat))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr_comma_list1) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'concat) in
    Obj.repr(
# 254 "parser.mly"
    ( _1 :: _3 )
# 866 "parser.ml"
               : 'concat))
; (fun __caml_parser_env ->
    Obj.repr(
# 258 "parser.mly"
    ( [ ] )
# 872 "parser.ml"
               : 'expr_comma_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'expr_comma_list1) in
    Obj.repr(
# 259 "parser.mly"
                     ( _1 )
# 879 "parser.ml"
               : 'expr_comma_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 263 "parser.mly"
         ( [ _1 ] )
# 886 "parser.ml"
               : 'expr_comma_list1))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr_comma_list1) in
    Obj.repr(
# 264 "parser.mly"
                                ( _1 :: _3 )
# 894 "parser.ml"
               : 'expr_comma_list1))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    Obj.repr(
# 269 "parser.mly"
    ( [ [], _2 ] )
# 901 "parser.ml"
               : 'switch_cases))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'switch_case) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'switch_cases) in
    Obj.repr(
# 271 "parser.mly"
    ( _1 :: _2 )
# 909 "parser.ml"
               : 'switch_cases))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 276 "parser.mly"
    ( [ _1 ] )
# 916 "parser.ml"
               : 'switch_pattern))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'expr_comma_list1) in
    Obj.repr(
# 278 "parser.mly"
    ( _2 )
# 923 "parser.ml"
               : 'switch_pattern))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'switch_pattern) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 283 "parser.mly"
   ( _2, _4 )
# 931 "parser.ml"
               : 'switch_case))
(* Entry file *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let file (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : Ast.expression)