# 16 "lexer.mll"
 

(* Prelude part: this is pure Caml. *)

open Lexing;;
open Parser;;

(** {6 Lexing errors} *)

type error =
   | Illegal_character of char
   | Illegal_escape of string
   | Unterminated_string
(** The various errors when lexing. *)
;;

exception Error of error * Lexing.position * Lexing.position;;

(** {6 Explaining lexing errors} *)

let report_error ppf = function
  | Illegal_character c ->
      Format.fprintf ppf "Illegal character (%C)" c
  | Illegal_escape s ->
      Format.fprintf ppf "Illegal escape (%S)" s
  | Unterminated_string ->
      Format.fprintf ppf "Unterminated string"
;;

(** {6 The keyword table} *)

let dot_keyword_table = Hashtbl.create 42;;

List.iter
 (fun (kwd, tok) -> Hashtbl.add dot_keyword_table kwd tok) [
  ".if", DOT_IF;
  ".then", DOT_THEN;
  ".else", DOT_ELSE;
  ".end", DOT_END;
  ".switch", DOT_SWITCH;
  ".case", DOT_CASE;
  ".otherwise", DOT_OTHERWISE;
  ".end", DOT_END;
]
;;

let token_of_dot_lowercase_ident s =
  assert (String.length s > 0);
  try Hashtbl.find dot_keyword_table s with
  | Not_found -> DOT_IDENT (String.sub s 1 (String.length s - 1))
;;

let keyword_table = Hashtbl.create 42;;

List.iter
 (fun (kwd, tok) -> Hashtbl.add keyword_table kwd tok) [
  "if", IF;
  "then", THEN;
  "else", ELSE;
  "end", END;
]
;;

let token_of_lowercase_ident s =
  assert (String.length s > 0);
  try Hashtbl.find keyword_table s with
  | Not_found -> IDENT s
;;

(** {6 Keeping the internal buffer locations up to date} *)

let update_loc lexbuf fname line absolute chars =
  let pos = lexbuf.lex_curr_p in
  let new_fname =
    match fname with
    | None -> pos.pos_fname
    | Some s -> s in
  lexbuf.lex_curr_p <- {
    pos with
    pos_fname = new_fname;
    pos_lnum = if absolute then line else pos.pos_lnum + line;
    pos_bol = pos.pos_cnum - chars;
  }
;;

(** Add one to the current line counter of the file being lexed. *)
let incr_line_num lexbuf =
  update_loc lexbuf None 1 false 0
;;

(** {6 Lexing the string tokens} *)
let initial_string_buffer = String.create 256;;

let string_buff = ref initial_string_buffer
and string_index = ref 0
;;

let string_start_pos = ref None;;

let reset_string_buffer () =
  string_buff := initial_string_buffer;
  string_index := 0
;;

let store_string_char c =
  if !string_index >= String.length !string_buff then begin
    let new_buff = String.create (String.length !string_buff * 2) in
      String.blit !string_buff 0
                  new_buff 0 (String.length !string_buff);
      string_buff := new_buff
  end;
  String.unsafe_set !string_buff !string_index c;
  incr string_index
;;

let get_stored_string () =
  let s = String.sub !string_buff 0 !string_index in
  string_buff := initial_string_buffer;
  s
;;

let char_for_character = function
  | '\\' -> '\\'
  | '\"' -> '\"'
  | 'n' -> '\n'
  | 't' -> '\t'
  | 'b' -> '\b'
  | 'r' -> '\r'
  | c ->
    failwith
      (Printf.sprintf "polish: lexer error, unknown escaped character %C" c)
;;


# 137 "lexer.ml"
let __ocaml_lex_tables = {
  Lexing.lex_base = 
   "\000\000\217\255\218\255\001\000\221\255\222\255\224\255\226\255\
    \227\255\228\255\229\255\230\255\231\255\232\255\002\000\003\000\
    \034\000\035\000\066\000\067\000\092\000\007\000\243\255\244\255\
    \085\000\246\255\247\255\248\255\085\000\163\000\238\000\252\255\
    \062\001\142\001\226\001\047\002\001\002\005\000\255\255\069\002\
    \081\002\103\002\113\002\135\002\238\255\239\255\240\255\241\255\
    \242\255\161\002\236\002\060\003\140\003\215\003\034\004\109\004\
    \184\004\003\005\030\001\006\000\219\255\019\000\237\255\106\000\
    \236\255\235\255\233\255\007\000\220\255\031\001\107\002\251\255\
    \252\255\060\005\255\255\253\255\254\255";
  Lexing.lex_backtrk = 
   "\002\000\255\255\255\255\038\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\032\000\021\000\
    \021\000\020\000\020\000\020\000\038\000\038\000\255\255\255\255\
    \010\000\255\255\255\255\255\255\006\000\006\000\004\000\255\255\
    \006\000\006\000\002\000\002\000\001\000\000\000\255\255\255\255\
    \002\000\002\000\002\000\255\255\255\255\255\255\255\255\255\255\
    \255\255\005\000\005\000\005\000\005\000\002\000\002\000\002\000\
    \002\000\004\000\255\255\036\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\035\000\255\255\255\255\255\255\255\255\
    \255\255\004\000\255\255\255\255\255\255";
  Lexing.lex_default = 
   "\001\000\000\000\000\000\069\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\000\000\000\000\
    \255\255\000\000\000\000\000\000\255\255\255\255\255\255\000\000\
    \255\255\255\255\255\255\255\255\255\255\255\255\000\000\255\255\
    \255\255\255\255\255\255\255\255\000\000\000\000\000\000\000\000\
    \000\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\058\000\255\255\000\000\255\255\000\000\255\255\
    \000\000\000\000\000\000\255\255\000\000\069\000\071\000\000\000\
    \000\000\075\000\000\000\000\000\000\000";
  Lexing.lex_trans = 
   "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\036\000\038\000\068\000\036\000\037\000\067\000\038\000\
    \060\000\068\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \036\000\015\000\031\000\000\000\005\000\003\000\020\000\004\000\
    \013\000\012\000\025\000\027\000\007\000\026\000\034\000\024\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\014\000\006\000\019\000\017\000\018\000\066\000\
    \065\000\028\000\028\000\028\000\032\000\032\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\011\000\023\000\010\000\022\000\065\000\
    \065\000\029\000\029\000\029\000\033\000\033\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\030\000\029\000\029\000\
    \029\000\029\000\029\000\009\000\021\000\008\000\016\000\065\000\
    \065\000\065\000\063\000\061\000\058\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\062\000\
    \064\000\000\000\000\000\000\000\000\000\000\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \000\000\000\000\000\000\000\000\028\000\000\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \000\000\000\000\000\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\000\000\000\000\
    \002\000\255\255\029\000\000\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\057\000\
    \057\000\057\000\057\000\057\000\057\000\057\000\057\000\057\000\
    \060\000\068\000\000\000\059\000\067\000\000\000\000\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\000\000\000\000\000\000\000\000\029\000\000\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\043\000\000\000\043\000\000\000\000\000\056\000\056\000\
    \056\000\056\000\056\000\056\000\056\000\056\000\056\000\056\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\000\000\000\000\000\000\000\000\028\000\000\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\043\000\000\000\043\000\000\000\000\000\055\000\055\000\
    \055\000\055\000\055\000\055\000\055\000\055\000\055\000\055\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\000\000\000\000\000\000\000\000\029\000\000\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\048\000\036\000\000\000\047\000\036\000\000\000\000\000\
    \000\000\046\000\041\000\041\000\041\000\041\000\041\000\041\000\
    \041\000\041\000\041\000\041\000\000\000\000\000\255\255\255\255\
    \000\000\036\000\000\000\049\000\049\000\049\000\051\000\051\000\
    \049\000\049\000\049\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\000\000\045\000\000\000\
    \044\000\000\000\000\000\050\000\050\000\050\000\052\000\052\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\040\000\000\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \043\000\000\000\043\000\039\000\039\000\042\000\042\000\042\000\
    \042\000\042\000\042\000\042\000\042\000\042\000\042\000\000\000\
    \000\000\041\000\041\000\041\000\041\000\041\000\041\000\041\000\
    \041\000\041\000\041\000\000\000\000\000\074\000\035\000\000\000\
    \000\000\000\000\000\000\039\000\039\000\039\000\039\000\041\000\
    \041\000\041\000\041\000\041\000\041\000\041\000\041\000\041\000\
    \041\000\042\000\042\000\042\000\042\000\042\000\042\000\042\000\
    \042\000\042\000\042\000\039\000\039\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\039\000\039\000\042\000\
    \042\000\042\000\042\000\042\000\042\000\042\000\042\000\042\000\
    \042\000\000\000\000\000\000\000\000\000\000\000\041\000\073\000\
    \000\000\000\000\000\000\039\000\039\000\000\000\000\000\000\000\
    \042\000\049\000\049\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\049\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\000\000\000\000\000\000\000\000\
    \049\000\000\000\049\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\050\000\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\000\000\
    \000\000\000\000\000\000\050\000\000\000\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\043\000\
    \000\000\043\000\000\000\072\000\054\000\054\000\054\000\054\000\
    \054\000\054\000\054\000\054\000\054\000\054\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\049\000\049\000\000\000\
    \000\000\000\000\000\000\049\000\000\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\049\000\049\000\043\000\
    \000\000\043\000\000\000\000\000\053\000\053\000\053\000\053\000\
    \053\000\053\000\053\000\053\000\053\000\053\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\000\000\
    \000\000\000\000\000\000\050\000\000\000\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\053\000\
    \053\000\053\000\053\000\053\000\053\000\053\000\053\000\053\000\
    \053\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\050\000\
    \050\000\050\000\000\000\000\000\000\000\000\000\053\000\000\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\050\000\
    \050\000\050\000\054\000\054\000\054\000\054\000\054\000\054\000\
    \054\000\054\000\054\000\054\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\000\000\000\000\000\000\
    \000\000\054\000\000\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\055\000\055\000\055\000\
    \055\000\055\000\055\000\055\000\055\000\055\000\055\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \000\000\000\000\000\000\000\000\055\000\000\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \056\000\056\000\056\000\056\000\056\000\056\000\056\000\056\000\
    \056\000\056\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\000\000\000\000\000\000\000\000\056\000\
    \000\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\057\000\057\000\057\000\057\000\057\000\
    \057\000\057\000\057\000\057\000\057\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\076\000\000\000\
    \000\000\000\000\029\000\000\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \076\000\000\000\000\000\000\000\000\000\000\000\076\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\076\000\000\000\000\000\000\000\076\000\000\000\
    \076\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\255\255";
  Lexing.lex_check = 
   "\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\000\000\000\000\003\000\000\000\000\000\003\000\037\000\
    \059\000\067\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \000\000\000\000\000\000\255\255\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\014\000\
    \015\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\016\000\
    \017\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\018\000\
    \019\000\019\000\020\000\021\000\024\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\061\000\
    \063\000\255\255\255\255\255\255\255\255\255\255\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \255\255\255\255\255\255\255\255\028\000\255\255\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \255\255\255\255\255\255\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\255\255\255\255\
    \000\000\003\000\029\000\255\255\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\030\000\030\000\
    \030\000\030\000\030\000\030\000\030\000\030\000\030\000\030\000\
    \058\000\069\000\255\255\058\000\069\000\255\255\255\255\030\000\
    \030\000\030\000\030\000\030\000\030\000\030\000\030\000\030\000\
    \030\000\030\000\030\000\030\000\030\000\030\000\030\000\030\000\
    \030\000\030\000\030\000\030\000\030\000\030\000\030\000\030\000\
    \030\000\255\255\255\255\255\255\255\255\030\000\255\255\030\000\
    \030\000\030\000\030\000\030\000\030\000\030\000\030\000\030\000\
    \030\000\030\000\030\000\030\000\030\000\030\000\030\000\030\000\
    \030\000\030\000\030\000\030\000\030\000\030\000\030\000\030\000\
    \030\000\032\000\255\255\032\000\255\255\255\255\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\255\255\255\255\255\255\255\255\032\000\255\255\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\033\000\255\255\033\000\255\255\255\255\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\033\000\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\033\000\
    \033\000\255\255\255\255\255\255\255\255\033\000\255\255\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\033\000\
    \033\000\034\000\036\000\255\255\034\000\036\000\255\255\255\255\
    \255\255\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\255\255\255\255\058\000\069\000\
    \255\255\036\000\255\255\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\255\255\034\000\255\255\
    \034\000\255\255\255\255\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\035\000\255\255\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \039\000\255\255\039\000\035\000\035\000\039\000\039\000\039\000\
    \039\000\039\000\039\000\039\000\039\000\039\000\039\000\255\255\
    \255\255\040\000\040\000\040\000\040\000\040\000\040\000\040\000\
    \040\000\040\000\040\000\255\255\255\255\070\000\035\000\255\255\
    \255\255\255\255\255\255\035\000\035\000\040\000\040\000\041\000\
    \041\000\041\000\041\000\041\000\041\000\041\000\041\000\041\000\
    \041\000\042\000\042\000\042\000\042\000\042\000\042\000\042\000\
    \042\000\042\000\042\000\041\000\041\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\040\000\040\000\043\000\
    \043\000\043\000\043\000\043\000\043\000\043\000\043\000\043\000\
    \043\000\255\255\255\255\255\255\255\255\255\255\041\000\070\000\
    \255\255\255\255\255\255\041\000\041\000\255\255\255\255\255\255\
    \042\000\049\000\049\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\049\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\255\255\255\255\255\255\255\255\
    \049\000\255\255\049\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\050\000\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\255\255\
    \255\255\255\255\255\255\050\000\255\255\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\050\000\050\000\051\000\
    \255\255\051\000\255\255\070\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\255\255\
    \255\255\255\255\255\255\051\000\255\255\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\052\000\
    \255\255\052\000\255\255\255\255\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\255\255\
    \255\255\255\255\255\255\052\000\255\255\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\053\000\
    \053\000\053\000\053\000\053\000\053\000\053\000\053\000\053\000\
    \053\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \053\000\053\000\053\000\053\000\053\000\053\000\053\000\053\000\
    \053\000\053\000\053\000\053\000\053\000\053\000\053\000\053\000\
    \053\000\053\000\053\000\053\000\053\000\053\000\053\000\053\000\
    \053\000\053\000\255\255\255\255\255\255\255\255\053\000\255\255\
    \053\000\053\000\053\000\053\000\053\000\053\000\053\000\053\000\
    \053\000\053\000\053\000\053\000\053\000\053\000\053\000\053\000\
    \053\000\053\000\053\000\053\000\053\000\053\000\053\000\053\000\
    \053\000\053\000\054\000\054\000\054\000\054\000\054\000\054\000\
    \054\000\054\000\054\000\054\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\054\000\054\000\054\000\054\000\054\000\
    \054\000\054\000\054\000\054\000\054\000\054\000\054\000\054\000\
    \054\000\054\000\054\000\054\000\054\000\054\000\054\000\054\000\
    \054\000\054\000\054\000\054\000\054\000\255\255\255\255\255\255\
    \255\255\054\000\255\255\054\000\054\000\054\000\054\000\054\000\
    \054\000\054\000\054\000\054\000\054\000\054\000\054\000\054\000\
    \054\000\054\000\054\000\054\000\054\000\054\000\054\000\054\000\
    \054\000\054\000\054\000\054\000\054\000\055\000\055\000\055\000\
    \055\000\055\000\055\000\055\000\055\000\055\000\055\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\055\000\055\000\
    \055\000\055\000\055\000\055\000\055\000\055\000\055\000\055\000\
    \055\000\055\000\055\000\055\000\055\000\055\000\055\000\055\000\
    \055\000\055\000\055\000\055\000\055\000\055\000\055\000\055\000\
    \255\255\255\255\255\255\255\255\055\000\255\255\055\000\055\000\
    \055\000\055\000\055\000\055\000\055\000\055\000\055\000\055\000\
    \055\000\055\000\055\000\055\000\055\000\055\000\055\000\055\000\
    \055\000\055\000\055\000\055\000\055\000\055\000\055\000\055\000\
    \056\000\056\000\056\000\056\000\056\000\056\000\056\000\056\000\
    \056\000\056\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\056\000\056\000\056\000\056\000\056\000\056\000\056\000\
    \056\000\056\000\056\000\056\000\056\000\056\000\056\000\056\000\
    \056\000\056\000\056\000\056\000\056\000\056\000\056\000\056\000\
    \056\000\056\000\056\000\255\255\255\255\255\255\255\255\056\000\
    \255\255\056\000\056\000\056\000\056\000\056\000\056\000\056\000\
    \056\000\056\000\056\000\056\000\056\000\056\000\056\000\056\000\
    \056\000\056\000\056\000\056\000\056\000\056\000\056\000\056\000\
    \056\000\056\000\056\000\057\000\057\000\057\000\057\000\057\000\
    \057\000\057\000\057\000\057\000\057\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\057\000\057\000\057\000\057\000\
    \057\000\057\000\057\000\057\000\057\000\057\000\057\000\057\000\
    \057\000\057\000\057\000\057\000\057\000\057\000\057\000\057\000\
    \057\000\057\000\057\000\057\000\057\000\057\000\073\000\255\255\
    \255\255\255\255\057\000\255\255\057\000\057\000\057\000\057\000\
    \057\000\057\000\057\000\057\000\057\000\057\000\057\000\057\000\
    \057\000\057\000\057\000\057\000\057\000\057\000\057\000\057\000\
    \057\000\057\000\057\000\057\000\057\000\057\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \073\000\255\255\255\255\255\255\255\255\255\255\073\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\073\000\255\255\255\255\255\255\073\000\255\255\
    \073\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\073\000";
  Lexing.lex_base_code = 
   "";
  Lexing.lex_backtrk_code = 
   "";
  Lexing.lex_default_code = 
   "";
  Lexing.lex_trans_code = 
   "";
  Lexing.lex_check_code = 
   "";
  Lexing.lex_code = 
   "";
}

let rec token lexbuf =
    __ocaml_lex_token_rec lexbuf 0
and __ocaml_lex_token_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 198 "lexer.mll"
    ( incr_line_num lexbuf;
      token lexbuf )
# 596 "lexer.ml"

  | 1 ->
# 201 "lexer.mll"
    ( token lexbuf )
# 601 "lexer.ml"

  | 2 ->
# 205 "lexer.mll"
    ( FLOAT (Lexing.lexeme lexbuf) )
# 606 "lexer.ml"

  | 3 ->
# 209 "lexer.mll"
    (
      reset_string_buffer ();
      string_start_pos :=
        Some (lexbuf.lex_start_p, lexbuf.lex_curr_p);
      string lexbuf;
      STRING (get_stored_string ())
    )
# 617 "lexer.ml"

  | 4 ->
# 219 "lexer.mll"
    ( PARAM (Lexing.lexeme lexbuf) )
# 622 "lexer.ml"

  | 5 ->
# 223 "lexer.mll"
    ( token_of_dot_lowercase_ident (Lexing.lexeme lexbuf) )
# 627 "lexer.ml"

  | 6 ->
# 227 "lexer.mll"
    ( token_of_lowercase_ident (Lexing.lexeme lexbuf) )
# 632 "lexer.ml"

  | 7 ->
# 229 "lexer.mll"
        ( PLUS_OP "+" )
# 637 "lexer.ml"

  | 8 ->
# 230 "lexer.mll"
        ( DASH_OP "-" )
# 642 "lexer.ml"

  | 9 ->
# 231 "lexer.mll"
        ( STAR_OP "*" )
# 647 "lexer.ml"

  | 10 ->
# 232 "lexer.mll"
        ( SLASH_OP "/" )
# 652 "lexer.ml"

  | 11 ->
# 233 "lexer.mll"
         ( BACKSLASH_OP "\\" )
# 657 "lexer.ml"

  | 12 ->
# 234 "lexer.mll"
        ( HAT_OP "^" )
# 662 "lexer.ml"

  | 13 ->
# 236 "lexer.mll"
          ( DOT_QUOTE_OP ".\'" )
# 667 "lexer.ml"

  | 14 ->
# 237 "lexer.mll"
         ( DOT_STAR_OP ".*" )
# 672 "lexer.ml"

  | 15 ->
# 238 "lexer.mll"
         ( DOT_SLASH_OP "./" )
# 677 "lexer.ml"

  | 16 ->
# 239 "lexer.mll"
          ( DOT_BACKSLASH_OP ".\\" )
# 682 "lexer.ml"

  | 17 ->
# 240 "lexer.mll"
         ( DOT_HAT_OP ".^" )
# 687 "lexer.ml"

  | 18 ->
# 242 "lexer.mll"
             ( BAR_BAR_OP (Lexing.lexeme lexbuf) )
# 692 "lexer.ml"

  | 19 ->
# 243 "lexer.mll"
             ( AMPER_AMPER_OP (Lexing.lexeme lexbuf) )
# 697 "lexer.ml"

  | 20 ->
# 246 "lexer.mll"
    ( COMPARE_OP (Lexing.lexeme lexbuf) )
# 702 "lexer.ml"

  | 21 ->
# 248 "lexer.mll"
              ( NOT_OP (Lexing.lexeme lexbuf) )
# 707 "lexer.ml"

  | 22 ->
# 250 "lexer.mll"
         ( COLON_EQUAL )
# 712 "lexer.ml"

  | 23 ->
# 253 "lexer.mll"
        ( LPAREN )
# 717 "lexer.ml"

  | 24 ->
# 254 "lexer.mll"
        ( RPAREN )
# 722 "lexer.ml"

  | 25 ->
# 255 "lexer.mll"
        ( LBRACKET )
# 727 "lexer.ml"

  | 26 ->
# 256 "lexer.mll"
        ( RBRACKET )
# 732 "lexer.ml"

  | 27 ->
# 257 "lexer.mll"
        ( LBRACE )
# 737 "lexer.ml"

  | 28 ->
# 258 "lexer.mll"
        ( RBRACE )
# 742 "lexer.ml"

  | 29 ->
# 259 "lexer.mll"
        ( COMMA )
# 747 "lexer.ml"

  | 30 ->
# 260 "lexer.mll"
        ( DOT )
# 752 "lexer.ml"

  | 31 ->
# 261 "lexer.mll"
        ( SEMI )
# 757 "lexer.ml"

  | 32 ->
# 262 "lexer.mll"
        ( COLON )
# 762 "lexer.ml"

  | 33 ->
# 263 "lexer.mll"
        ( DOLLAR )
# 767 "lexer.ml"

  | 34 ->
# 264 "lexer.mll"
         ( QUOTE )
# 772 "lexer.ml"

  | 35 ->
# 266 "lexer.mll"
    ( token lexbuf )
# 777 "lexer.ml"

  | 36 ->
# 268 "lexer.mll"
    ( token lexbuf )
# 782 "lexer.ml"

  | 37 ->
# 270 "lexer.mll"
        ( EOF )
# 787 "lexer.ml"

  | 38 ->
# 272 "lexer.mll"
    ( raise
        (Error
           (Illegal_character
              (Lexing.lexeme_char lexbuf 0),
              lexbuf.lex_start_p,
              lexbuf.lex_curr_p)) )
# 797 "lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; __ocaml_lex_token_rec lexbuf __ocaml_lex_state

and string lexbuf =
    __ocaml_lex_string_rec lexbuf 70
and __ocaml_lex_string_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 281 "lexer.mll"
    ( () )
# 808 "lexer.ml"

  | 1 ->
# 283 "lexer.mll"
    ( store_string_char (char_for_character (Lexing.lexeme_char lexbuf 1));
      string lexbuf )
# 814 "lexer.ml"

  | 2 ->
# 286 "lexer.mll"
    ( raise
        (Error
           (Illegal_escape (Lexing.lexeme lexbuf),
           lexbuf.lex_start_p,
           lexbuf.lex_curr_p)) )
# 823 "lexer.ml"

  | 3 ->
# 292 "lexer.mll"
    ( match !string_start_pos with
      | Some (start_pos, end_pos) ->
        raise (Error (Unterminated_string, start_pos, end_pos))
      | _ -> assert false )
# 831 "lexer.ml"

  | 4 ->
# 297 "lexer.mll"
    ( store_string_char (Lexing.lexeme_char lexbuf 0);
      string lexbuf )
# 837 "lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; __ocaml_lex_string_rec lexbuf __ocaml_lex_state

;;
