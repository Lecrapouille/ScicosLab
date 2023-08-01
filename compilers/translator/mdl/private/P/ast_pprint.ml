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

(* $Id: ast_pprint.ml 4846 2013-04-30 17:53:18Z weis $ *)

open Ast;;
open Format;;

let rec print ppf = function
  | E_colon -> fprintf ppf "%s" ":"
  | E_dollar -> fprintf ppf "%s" "$"
  | E_number n -> fprintf ppf "%s" n
  | E_string s -> fprintf ppf "%S" s
  | E_matrix ll -> fprintf ppf "[%a]" print_elems ll
  | E_variable v -> fprintf ppf "%s" v
  | E_parameter v -> fprintf ppf "%s" v
  | E_if (cond, e_then, e_else) ->
    fprintf ppf "if_then_else (%a, %a, %a)"
    print cond print e_then print e_else
  | E_apply (e_f, e_args) ->
    fprintf ppf "%a (%a)"
    print e_f print_args e_args
  | E_unary (op, x) ->
    fprintf ppf "%s (%a)"
      op
      print x
  | E_binary (op, x, y) ->
    fprintf ppf "%a %s %a"
      print x
      op
      print y
  | E_paren e ->
    fprintf ppf "(%a)" print e
  | E_bracket e ->
    fprintf ppf "[%a]" print e
  | E_record_access (e1, label) ->
    fprintf ppf "%a.%s"
      print e1
      label
  | E_switch switch_desc ->
    fprintf ppf "@[<v2>switch %a@]"
      print_switch_desc switch_desc

and print_switch_desc ppf switch_desc =
  match switch_desc with
  | {
      switch_subject = e;
      switch_cases = cls;
      switch_default = d;
    } ->
    fprintf ppf "%a%a%a"
      print e
      (fun ppf ->
       List.iter (fun (e1, e2) ->
         fprintf ppf "@ @[%a,@ %a@]" print e1 print e2))
      cls
      (fun ppf d ->
       fprintf ppf "@ otherwise %a@ end"
         print d)
      d

and print_args ppf = function
  | [] -> ()
  | arg :: args ->
    print ppf arg;
    List.iter (function arg -> fprintf ppf ", %a" print arg) args

and print_elems ppf =
  List.iter (fun r ->
    fprintf ppf "%a;@ " print_args r)
;;

let rec print_command ppf = function
  | C_if (cond, c_then, c_else) ->
    fprintf ppf "if %a then %a; else %a; end"
    print cond print_command c_then print_command c_else
  | C_paren c ->
    fprintf ppf "(%a)" print_command c
;;

let pprint_expression = print
and pprint_command = print_command
;;
