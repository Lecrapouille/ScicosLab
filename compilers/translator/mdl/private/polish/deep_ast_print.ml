(* Beginning of ocamlprintc generated code *)

open Deep_ast;;

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


(* $Id: deep_ast_print.ml 4691 2012-01-05 17:54:45Z weis $ *)


open Ast;;

open Ast_print;;

let rec print_unop ppf = function
  | Uabs -> Format.fprintf ppf "Uabs" | Uand -> Format.fprintf ppf "Uand"
  | Uacos -> Format.fprintf ppf "Uacos"
  | Uacosh -> Format.fprintf ppf "Uacosh"
  | Uasin -> Format.fprintf ppf "Uasin"
  | Uasinh -> Format.fprintf ppf "Uasinh"
  | Uatan -> Format.fprintf ppf "Uatan"
  | Uatanh -> Format.fprintf ppf "Uatanh"
  | Uceil -> Format.fprintf ppf "Uceil"
  | Ucolon -> Format.fprintf ppf "Ucolon" | Ucos -> Format.fprintf ppf "Ucos"
  | Ucosh -> Format.fprintf ppf "Ucosh" | Uexp -> Format.fprintf ppf "Uexp"
  | Uexpm -> Format.fprintf ppf "Uexpm"
  | Ufloor -> Format.fprintf ppf "Ufloor" | Uint -> Format.fprintf ppf "Uint"
  | Uinv -> Format.fprintf ppf "Uinv" | Ulog -> Format.fprintf ppf "Ulog"
  | Ulog10 -> Format.fprintf ppf "Ulog10"
  | Ulogm -> Format.fprintf ppf "Ulogm" | Uor -> Format.fprintf ppf "Uor"
  | Umin -> Format.fprintf ppf "Umin" | Umax -> Format.fprintf ppf "Umax"
  | Uminus -> Format.fprintf ppf "Uminus" | Unot -> Format.fprintf ppf "Unot"
  | Ureshape -> Format.fprintf ppf "Ureshape"
  | Uround -> Format.fprintf ppf "Uround"
  | Usign -> Format.fprintf ppf "Usign" | Usin -> Format.fprintf ppf "Usin"
  | Usinh -> Format.fprintf ppf "Usinh"
  | Usizeprod -> Format.fprintf ppf "Usizeprod"
  | Usizecol -> Format.fprintf ppf "Usizecol"
  | Usizerow -> Format.fprintf ppf "Usizerow"
  | Usum -> Format.fprintf ppf "Usum"
  | Usumcol -> Format.fprintf ppf "Usumcol"
  | Usumrow -> Format.fprintf ppf "Usumrow"
  | Usvd -> Format.fprintf ppf "Usvd"
  | Utranspose -> Format.fprintf ppf "Utranspose"
  | Uctranspose -> Format.fprintf ppf "Uctranspose"
  | Usqrt -> Format.fprintf ppf "Usqrt" | Utan -> Format.fprintf ppf "Utan"
  | Utanh -> Format.fprintf ppf "Utanh" | Ueye -> Format.fprintf ppf "Ueye"
;;

let rec print_binop ppf = function
  | Badd -> Format.fprintf ppf "Badd" | Bsub -> Format.fprintf ppf "Bsub"
  | Bmul -> Format.fprintf ppf "Bmul" | Bdiv -> Format.fprintf ppf "Bdiv"
  | Bexp -> Format.fprintf ppf "Bexp" | Bldiv -> Format.fprintf ppf "Bldiv"
  | Beq -> Format.fprintf ppf "Beq" | Blt -> Format.fprintf ppf "Blt"
  | Bgt -> Format.fprintf ppf "Bgt" | Ble -> Format.fprintf ppf "Ble"
  | Bge -> Format.fprintf ppf "Bge" | Bne -> Format.fprintf ppf "Bne"
  | Blor -> Format.fprintf ppf "Blor" | Bland -> Format.fprintf ppf "Bland"
  | Blne -> Format.fprintf ppf "Blne" | Bmin -> Format.fprintf ppf "Bmin"
  | Bmax -> Format.fprintf ppf "Bmax" | Batan2 -> Format.fprintf ppf "Batan2"
  | Bmulm -> Format.fprintf ppf "Bmulm" | Bdivm -> Format.fprintf ppf "Bdivm"
  | Bldivm -> Format.fprintf ppf "Bldivm"
  | Bexpm -> Format.fprintf ppf "Bexpm"
  | Bhconc -> Format.fprintf ppf "Bhconc"
  | Bvconc -> Format.fprintf ppf "Bvconc"
  | Bextract -> Format.fprintf ppf "Bextract"
  | Bextract_all_columns -> Format.fprintf ppf "Bextract_all_columns"
  | Bextract_all_rows -> Format.fprintf ppf "Bextract_all_rows"
  | Bremove -> Format.fprintf ppf "Bremove"
  | Bremove_all_columns -> Format.fprintf ppf "Bremove_all_columns"
  | Bremove_all_rows -> Format.fprintf ppf "Bremove_all_rows"
  | Brange -> Format.fprintf ppf "Brange"
  | Bassign -> Format.fprintf ppf "Bassign"
  | Bones -> Format.fprintf ppf "Bones"
  | Bzeros -> Format.fprintf ppf "Bzeros"
;;

let rec print_ternop ppf = function
  | Textract -> Format.fprintf ppf "Textract"
  | Trange -> Format.fprintf ppf "Trange"
  | Tassign -> Format.fprintf ppf "Tassign"
  | Tassign_all_columns -> Format.fprintf ppf "Tassign_all_columns"
  | Tassign_all_rows -> Format.fprintf ppf "Tassign_all_rows"
  | Tmatrix -> Format.fprintf ppf "Tmatrix"
  | Tdotif -> Format.fprintf ppf "Tdotif"
;;

let rec print_sci_op ppf = function
  | Dotswitch -> Format.fprintf ppf "Dotswitch"
;;

let rec print_quaternop ppf = function
  | Qassign -> Format.fprintf ppf "Qassign"
  | Qdotswitchcase -> Format.fprintf ppf "Qdotswitchcase"
;;

let rec print_label = (fun ppf s -> Lib_print.print_quoted_string ppf s)
;;

let rec print_expression ppf = function
  | D_colon -> Format.fprintf ppf "D_colon"
  | D_dollar -> Format.fprintf ppf "D_dollar"
  | D_number s ->
     Format.fprintf ppf "@[<1>(%s@ " "D_number";
     Lib_print.print_quoted_string ppf s; Format.fprintf ppf ")@]"
  | D_string s ->
     Format.fprintf ppf "@[<1>(%s@ " "D_string";
     Lib_print.print_quoted_string ppf s; Format.fprintf ppf ")@]"
  | D_matrix e_l_l ->
     Format.fprintf ppf "@[<1>(%s@ " "D_matrix";
     Lib_print.print_List (Lib_print.print_List print_expression) ppf e_l_l;
     Format.fprintf ppf ")@]"
  | D_variable s ->
     Format.fprintf ppf "@[<1>(%s@ " "D_variable";
     Lib_print.print_quoted_string ppf s; Format.fprintf ppf ")@]"
  | D_parameter i ->
     Format.fprintf ppf "@[<1>(%s@ " "D_parameter";
     Lib_print.print_quoted_int ppf i; Format.fprintf ppf ")@]"
  | D_accu e ->
     Format.fprintf ppf "@[<1>(%s@ " "D_accu"; print_expression ppf e;
     Format.fprintf ppf ")@]"
  | D_if (e, e0, e1) ->
     Format.fprintf ppf "@[<1>(%s@ " "D_if"; Format.fprintf ppf "@[<1>(";
     Format.fprintf ppf "@[<1>("; print_expression ppf e;
     Format.fprintf ppf ",@ "; print_expression ppf e0;
     Format.fprintf ppf ",@ "; print_expression ppf e1;
     Format.fprintf ppf ")@]"; Format.fprintf ppf "@,)@]";
     Format.fprintf ppf ")@]"
  | D_switch s ->
     Format.fprintf ppf "@[<1>(%s@ " "D_switch"; print_switch_desc ppf s;
     Format.fprintf ppf ")@]"
  | D_unary (u, e) ->
     Format.fprintf ppf "@[<1>(%s@ " "D_unary"; Format.fprintf ppf "@[<1>(";
     Format.fprintf ppf "@[<1>("; print_unop ppf u; Format.fprintf ppf ",@ ";
     print_expression ppf e; Format.fprintf ppf ")@]";
     Format.fprintf ppf "@,)@]"; Format.fprintf ppf ")@]"
  | D_binary (b, e, e0) ->
     Format.fprintf ppf "@[<1>(%s@ " "D_binary"; Format.fprintf ppf "@[<1>(";
     Format.fprintf ppf "@[<1>("; print_binop ppf b;
     Format.fprintf ppf ",@ "; print_expression ppf e;
     Format.fprintf ppf ",@ "; print_expression ppf e0;
     Format.fprintf ppf ")@]"; Format.fprintf ppf "@,)@]";
     Format.fprintf ppf ")@]"
  | D_ternary (t, e, e0, e1) ->
     Format.fprintf ppf "@[<1>(%s@ " "D_ternary";
     Format.fprintf ppf "@[<1>("; Format.fprintf ppf "@[<1>(";
     print_ternop ppf t; Format.fprintf ppf ",@ "; print_expression ppf e;
     Format.fprintf ppf ",@ "; print_expression ppf e0;
     Format.fprintf ppf ",@ "; print_expression ppf e1;
     Format.fprintf ppf ")@]"; Format.fprintf ppf "@,)@]";
     Format.fprintf ppf ")@]"
  | D_quaternary (q, e, e0, e1, e2) ->
     Format.fprintf ppf "@[<1>(%s@ " "D_quaternary";
     Format.fprintf ppf "@[<1>("; Format.fprintf ppf "@[<1>(";
     print_quaternop ppf q; Format.fprintf ppf ",@ "; print_expression ppf e;
     Format.fprintf ppf ",@ "; print_expression ppf e0;
     Format.fprintf ppf ",@ "; print_expression ppf e1;
     Format.fprintf ppf ",@ "; print_expression ppf e2;
     Format.fprintf ppf ")@]"; Format.fprintf ppf "@,)@]";
     Format.fprintf ppf ")@]"
  | D_apply (e, e_l) ->
     Format.fprintf ppf "@[<1>(%s@ " "D_apply"; Format.fprintf ppf "@[<1>(";
     Format.fprintf ppf "@[<1>("; print_expression ppf e;
     Format.fprintf ppf ",@ "; Lib_print.print_List print_expression ppf e_l;
     Format.fprintf ppf ")@]"; Format.fprintf ppf "@,)@]";
     Format.fprintf ppf ")@]"
  | D_record_access (e, l) ->
     Format.fprintf ppf "@[<1>(%s@ " "D_record_access";
     Format.fprintf ppf "@[<1>("; Format.fprintf ppf "@[<1>(";
     print_expression ppf e; Format.fprintf ppf ",@ "; print_label ppf l;
     Format.fprintf ppf ")@]"; Format.fprintf ppf "@,)@]";
     Format.fprintf ppf ")@]"
  | D_bracket e ->
     Format.fprintf ppf "@[<1>(%s@ " "D_bracket"; print_expression ppf e;
     Format.fprintf ppf ")@]"
  | D_paren e ->
     Format.fprintf ppf "@[<1>(%s@ " "D_paren"; print_expression ppf e;
     Format.fprintf ppf ")@]"

and print_switch_desc ppf = function
  { dswitch_subject = e; dswitch_cases = c; dswitch_default = e0; } ->
    Format.fprintf ppf "@[<1>{";
    Format.fprintf ppf "@[<1>dswitch_subject =@ "; print_expression ppf e;
    Format.fprintf ppf ";@]@ "; Format.fprintf ppf "@[<1>dswitch_cases =@ ";
    print_clauses ppf c; Format.fprintf ppf ";@]@ ";
    Format.fprintf ppf "@[<1>dswitch_default =@ "; print_expression ppf e0;
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
