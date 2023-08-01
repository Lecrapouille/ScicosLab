(* Beginning of ocamlprintc generated code *)

open Splice_ast;;

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


(* $Id: splice_ast_print.ml 4691 2012-01-05 17:54:45Z weis $ *)


open Ast;;

open Ast_print;;

(* For list1 *)

open Deep_ast;;

open Deep_ast_print;;

(* For unop and binop and label *)


let rec print_expression ppf = function
  | S_colon -> Format.fprintf ppf "S_colon"
  | S_dollar -> Format.fprintf ppf "S_dollar"
  | S_number s ->
     Format.fprintf ppf "@[<1>(%s@ " "S_number";
     Lib_print.print_quoted_string ppf s; Format.fprintf ppf ")@]"
  | S_string s ->
     Format.fprintf ppf "@[<1>(%s@ " "S_string";
     Lib_print.print_quoted_string ppf s; Format.fprintf ppf ")@]"
  | S_matrix e_l_l ->
     Format.fprintf ppf "@[<1>(%s@ " "S_matrix";
     Lib_print.print_List (Lib_print.print_List print_expression) ppf e_l_l;
     Format.fprintf ppf ")@]"
  | S_variable s ->
     Format.fprintf ppf "@[<1>(%s@ " "S_variable";
     Lib_print.print_quoted_string ppf s; Format.fprintf ppf ")@]"
  | S_parameter i ->
     Format.fprintf ppf "@[<1>(%s@ " "S_parameter";
     Lib_print.print_quoted_int ppf i; Format.fprintf ppf ")@]"
  | S_if (e, e0, e1) ->
     Format.fprintf ppf "@[<1>(%s@ " "S_if"; Format.fprintf ppf "@[<1>(";
     Format.fprintf ppf "@[<1>("; print_expression ppf e;
     Format.fprintf ppf ",@ "; print_expression ppf e0;
     Format.fprintf ppf ",@ "; print_expression ppf e1;
     Format.fprintf ppf ")@]"; Format.fprintf ppf "@,)@]";
     Format.fprintf ppf ")@]"
  | S_switch s ->
     Format.fprintf ppf "@[<1>(%s@ " "S_switch"; print_switch_desc ppf s;
     Format.fprintf ppf ")@]"
  | S_unary (u, e) ->
     Format.fprintf ppf "@[<1>(%s@ " "S_unary"; Format.fprintf ppf "@[<1>(";
     Format.fprintf ppf "@[<1>("; print_unop ppf u; Format.fprintf ppf ",@ ";
     print_expression ppf e; Format.fprintf ppf ")@]";
     Format.fprintf ppf "@,)@]"; Format.fprintf ppf ")@]"
  | S_binary (b, e, e0) ->
     Format.fprintf ppf "@[<1>(%s@ " "S_binary"; Format.fprintf ppf "@[<1>(";
     Format.fprintf ppf "@[<1>("; print_binop ppf b;
     Format.fprintf ppf ",@ "; print_expression ppf e;
     Format.fprintf ppf ",@ "; print_expression ppf e0;
     Format.fprintf ppf ")@]"; Format.fprintf ppf "@,)@]";
     Format.fprintf ppf ")@]"
  | S_ternary (t, e, e0, e1) ->
     Format.fprintf ppf "@[<1>(%s@ " "S_ternary";
     Format.fprintf ppf "@[<1>("; Format.fprintf ppf "@[<1>(";
     print_ternop ppf t; Format.fprintf ppf ",@ "; print_expression ppf e;
     Format.fprintf ppf ",@ "; print_expression ppf e0;
     Format.fprintf ppf ",@ "; print_expression ppf e1;
     Format.fprintf ppf ")@]"; Format.fprintf ppf "@,)@]";
     Format.fprintf ppf ")@]"
  | S_quaternary (q, e, e0, e1, e2) ->
     Format.fprintf ppf "@[<1>(%s@ " "S_quaternary";
     Format.fprintf ppf "@[<1>("; Format.fprintf ppf "@[<1>(";
     print_quaternop ppf q; Format.fprintf ppf ",@ "; print_expression ppf e;
     Format.fprintf ppf ",@ "; print_expression ppf e0;
     Format.fprintf ppf ",@ "; print_expression ppf e1;
     Format.fprintf ppf ",@ "; print_expression ppf e2;
     Format.fprintf ppf ")@]"; Format.fprintf ppf "@,)@]";
     Format.fprintf ppf ")@]"
  | S_apply (e, e_l) ->
     Format.fprintf ppf "@[<1>(%s@ " "S_apply"; Format.fprintf ppf "@[<1>(";
     Format.fprintf ppf "@[<1>("; print_expression ppf e;
     Format.fprintf ppf ",@ "; Lib_print.print_List print_expression ppf e_l;
     Format.fprintf ppf ")@]"; Format.fprintf ppf "@,)@]";
     Format.fprintf ppf ")@]"
  | S_record_access (e, l) ->
     Format.fprintf ppf "@[<1>(%s@ " "S_record_access";
     Format.fprintf ppf "@[<1>("; Format.fprintf ppf "@[<1>(";
     print_expression ppf e; Format.fprintf ppf ",@ "; print_label ppf l;
     Format.fprintf ppf ")@]"; Format.fprintf ppf "@,)@]";
     Format.fprintf ppf ")@]"
  | S_paren e ->
     Format.fprintf ppf "@[<1>(%s@ " "S_paren"; print_expression ppf e;
     Format.fprintf ppf ")@]"
  | S_bracket e ->
     Format.fprintf ppf "@[<1>(%s@ " "S_bracket"; print_expression ppf e;
     Format.fprintf ppf ")@]"
  | S_splice e ->
     Format.fprintf ppf "@[<1>(%s@ " "S_splice"; print_expression ppf e;
     Format.fprintf ppf ")@]"

and print_switch_desc ppf = function
  { sswitch_subject = e; sswitch_cases = c; sswitch_default = e0; } ->
    Format.fprintf ppf "@[<1>{";
    Format.fprintf ppf "@[<1>sswitch_subject =@ "; print_expression ppf e;
    Format.fprintf ppf ";@]@ "; Format.fprintf ppf "@[<1>sswitch_cases =@ ";
    print_clauses ppf c; Format.fprintf ppf ";@]@ ";
    Format.fprintf ppf "@[<1>sswitch_default =@ "; print_expression ppf e0;
    Format.fprintf ppf ";@]@ "; Format.fprintf ppf "@,}@]"

and print_clauses =
  (fun ppf c_l -> Lib_print.print_List print_clause ppf c_l)

and print_clause =
  (fun ppf (p_l, e) ->
    Format.fprintf ppf "@[<1>("; Format.fprintf ppf "@[<1>(";
    Lib_print.print_List print_pattern ppf p_l; Format.fprintf ppf ",@ ";
    print_expression ppf e; Format.fprintf ppf ")@]";
    Format.fprintf ppf "@,)@]")

and print_pattern = (fun ppf e -> print_expression ppf e)
;;

(* End of /usr/local/bin/ocamlprintc generated code *)
