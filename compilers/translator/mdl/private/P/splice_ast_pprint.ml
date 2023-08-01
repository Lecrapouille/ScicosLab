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

(* $Id: splice_ast_pprint.ml 4846 2013-04-30 17:53:18Z weis $ *)

open Format;;
open Splice_ast;;

let rec pprint ppf = function
  | S_colon -> fprintf ppf "%s" ":"
  | S_dollar -> fprintf ppf "%s" "$"
  | S_string n -> fprintf ppf "%S" n
  | S_number n -> fprintf ppf "%s" n
  | S_matrix exprs -> fprintf ppf "%a" print_elems exprs
  | S_variable v -> fprintf ppf "%s" v
  | S_parameter p -> fprintf ppf "u%d" p
  | S_if (cond, e_then, e_else) ->
    fprintf ppf "if %a then %a; else %a; end"
    pprint cond pprint e_then pprint e_else
  | S_apply (e_f, e_args) ->
    fprintf ppf "%a(%a)"
    pprint e_f print_args e_args
  | S_unary (op, x) ->
    let op = Transl.string_of_unop op in
    fprintf ppf "%s(%a)" op pprint x
  | S_binary (op, x, y) when Transl.is_prefix_binop op ->
    fprintf ppf "%s(%a, %a)"
      (Transl.string_of_binop op)
      pprint x
      pprint y
  | S_binary ((Deep_ast.Bhconc | Deep_ast.Bvconc as op), x, y) ->
    fprintf ppf "%a%s %a"
      pprint x
      (Transl.string_of_binop op)
      pprint y
  | S_binary (op, x, y) ->
    fprintf ppf "%a %s %a"
      pprint x
      (Transl.string_of_binop op)
      pprint y
  | S_ternary (op, x, y, z) ->
    fprintf ppf "%s(%a, %a, %a)"
      (Transl.string_of_ternop op)
      pprint x
      pprint y
      pprint z
  | S_quaternary (op, x, y, z, t) ->
    fprintf ppf "%s(%a, %a, %a, %a)"
      (Transl.string_of_quaternop op)
      pprint x
      pprint y
      pprint z
      pprint t
  | S_record_access (e1, label) ->
    fprintf ppf "%a.%s"
      pprint e1
      label
  | S_paren e ->
    fprintf ppf "(%a)" pprint e
  | S_bracket e ->
    fprintf ppf "[%a]" pprint e
  | S_splice e ->
    fprintf ppf "splice (%a)"
      pprint e

and print_args ppf = function
  | [] -> ()
  | arg :: args ->
    pprint ppf arg;
    List.iter
      (function arg -> fprintf ppf ",%a" pprint arg)
      args

and print_elems ppf = print_args ppf
;;

let pstring_of_spliced_expression e =
  pprint Format.str_formatter e;
  Format.flush_str_formatter ();
;;
