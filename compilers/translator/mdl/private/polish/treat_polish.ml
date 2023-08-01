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

(* $Id: treat_polish.ml 4691 2012-01-05 17:54:45Z weis $ *)

open Format;;

type operator = string;;

type config = {
  print_ast : bool;
  print_scope_ast : bool;
  print_transl_ast : bool;
  print_splice_ast : bool;
  print_idx : bool;
  print_globals : bool;
  print_code : bool;
  print_polish : bool;
}
;;

let config = {
  print_ast = false;
  print_scope_ast = false;
  print_transl_ast = false;
  print_splice_ast = false;
  print_idx = false;
  print_globals = false;
  print_code = false;
  print_polish = false;
}
;;

let debug_config = {
  print_ast = true;
  print_scope_ast = true;
  print_transl_ast = true;
  print_splice_ast = true;
  print_idx = true;
  print_globals = true;
  print_code = true;
  print_polish = true;
}
;;

let parse lexbuf =
  Parser.file Lexer.token lexbuf
;;

let parse_file fname =
  let ic = open_in fname in
  let lexbuf = Lexing.from_channel ic in
  let ast = parse lexbuf in
  close_in ic;
  ast
;;

let parse_string s =
  let lexbuf = Lexing.from_string s in
  parse lexbuf
;;

let print_globals ppf glbs =
  let pr_glbs ppf glbs =
    for i = 0 to Array.length glbs - 1 do
      Format.fprintf ppf "@ %d : %a; @ " (i + 1)
        Splice_ast_pprint.pprint glbs.(i)
    done in
  Format.fprintf ppf "[@[<v 2>%a@]@.]" pr_glbs glbs
;;

let treat_ast config ast =
  if config.print_ast then
    Format.printf "%a@." Ast_print.print_expression ast;

  if config.print_scope_ast then Format.printf "@.Scoping:@.";
  let ast = Scoping.scope ast in
  if config.print_scope_ast then
    Format.printf "%a@." Ast_print.print_expression ast;

  if config.print_transl_ast then Format.printf "@.Translating:@.";
  let ast = Transl.translate ast in
  if config.print_transl_ast then
    Format.printf "%a@." Deep_ast_print.print_expression ast;

  if config.print_splice_ast then Format.printf "@.Splicing:@.";
  let ast = Splicing.splice ast in
  if config.print_splice_ast then
    Format.printf "%a@." Splice_ast_print.print_expression ast;

  if config.print_idx then Format.printf "@.Compiling:@.";
  let idx, globals, code = Compile.compile ast in
  if config.print_idx then
    Format.printf "@.Final idx: %d@." idx;
  if config.print_globals then
    Format.printf "Globals are:@ %a@." print_globals globals;
  if config.print_code then
    Format.printf "Code is:@.%a@." Machine_print.print_code code;

  let ast = Polish.polish ast in
  if config.print_polish then
    Format.printf "@.Polishing:@.%a@." Print_polish.print ast;

  ast
;;

let treat_file_gen config fname =
  if config.print_ast then Format.printf "@.Parsing:@.";
  let ast = parse_file fname in
  treat_ast config ast
;;

let treat_string_gen config s =
  if config.print_ast then Format.printf "@.Parsing:@.";
  let ast = parse_string s in
  treat_ast config ast
;;

let treat_file = treat_file_gen debug_config
;;

let treat_string = treat_string_gen debug_config
;;
