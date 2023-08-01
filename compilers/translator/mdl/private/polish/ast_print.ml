(* Beginning of ocamlprintc generated code *)

open Ast;;

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


(* $Id: ast_print.ml 4691 2012-01-05 17:54:45Z weis $ *)


let rec print_operator = (fun ppf s -> Lib_print.print_quoted_string ppf s)
;;

let rec print_label = (fun ppf s -> Lib_print.print_quoted_string ppf s)
;;

let rec print_list1 pp_a =
  (fun ppf (a, a_l) ->
    Format.fprintf ppf "@[<1>("; Format.fprintf ppf "@[<1>("; pp_a ppf a;
    Format.fprintf ppf ",@ "; Lib_print.print_List pp_a ppf a_l;
    Format.fprintf ppf ")@]"; Format.fprintf ppf "@,)@]")
;;

let rec print_expression ppf = function
  | E_colon -> Format.fprintf ppf "E_colon"
  | E_dollar -> Format.fprintf ppf "E_dollar"
  | E_number s ->
     Format.fprintf ppf "@[<1>(%s@ " "E_number";
     Lib_print.print_quoted_string ppf s; Format.fprintf ppf ")@]"
  | E_string s ->
     Format.fprintf ppf "@[<1>(%s@ " "E_string";
     Lib_print.print_quoted_string ppf s; Format.fprintf ppf ")@]"
  | E_matrix e_l_l ->
     Format.fprintf ppf "@[<1>(%s@ " "E_matrix";
     Lib_print.print_List (Lib_print.print_List print_expression) ppf e_l_l;
     Format.fprintf ppf ")@]"
  | E_variable s ->
     Format.fprintf ppf "@[<1>(%s@ " "E_variable";
     Lib_print.print_quoted_string ppf s; Format.fprintf ppf ")@]"
  | E_parameter s ->
     Format.fprintf ppf "@[<1>(%s@ " "E_parameter";
     Lib_print.print_quoted_string ppf s; Format.fprintf ppf ")@]"
  | E_if (e, e0, e1) ->
     Format.fprintf ppf "@[<1>(%s@ " "E_if"; Format.fprintf ppf "@[<1>(";
     Format.fprintf ppf "@[<1>("; print_expression ppf e;
     Format.fprintf ppf ",@ "; print_expression ppf e0;
     Format.fprintf ppf ",@ "; print_expression ppf e1;
     Format.fprintf ppf ")@]"; Format.fprintf ppf "@,)@]";
     Format.fprintf ppf ")@]"
  | E_binary (o, e, e0) ->
     Format.fprintf ppf "@[<1>(%s@ " "E_binary"; Format.fprintf ppf "@[<1>(";
     Format.fprintf ppf "@[<1>("; print_operator ppf o;
     Format.fprintf ppf ",@ "; print_expression ppf e;
     Format.fprintf ppf ",@ "; print_expression ppf e0;
     Format.fprintf ppf ")@]"; Format.fprintf ppf "@,)@]";
     Format.fprintf ppf ")@]"
  | E_unary (o, e) ->
     Format.fprintf ppf "@[<1>(%s@ " "E_unary"; Format.fprintf ppf "@[<1>(";
     Format.fprintf ppf "@[<1>("; print_operator ppf o;
     Format.fprintf ppf ",@ "; print_expression ppf e;
     Format.fprintf ppf ")@]"; Format.fprintf ppf "@,)@]";
     Format.fprintf ppf ")@]"
  | E_apply (e, e_l) ->
     Format.fprintf ppf "@[<1>(%s@ " "E_apply"; Format.fprintf ppf "@[<1>(";
     Format.fprintf ppf "@[<1>("; print_expression ppf e;
     Format.fprintf ppf ",@ "; Lib_print.print_List print_expression ppf e_l;
     Format.fprintf ppf ")@]"; Format.fprintf ppf "@,)@]";
     Format.fprintf ppf ")@]"
  | E_record_access (e, l) ->
     Format.fprintf ppf "@[<1>(%s@ " "E_record_access";
     Format.fprintf ppf "@[<1>("; Format.fprintf ppf "@[<1>(";
     print_expression ppf e; Format.fprintf ppf ",@ "; print_label ppf l;
     Format.fprintf ppf ")@]"; Format.fprintf ppf "@,)@]";
     Format.fprintf ppf ")@]"
  | E_switch s ->
     Format.fprintf ppf "@[<1>(%s@ " "E_switch"; print_switch_desc ppf s;
     Format.fprintf ppf ")@]"
  | E_bracket e ->
     Format.fprintf ppf "@[<1>(%s@ " "E_bracket"; print_expression ppf e;
     Format.fprintf ppf ")@]"
  | E_paren e ->
     Format.fprintf ppf "@[<1>(%s@ " "E_paren"; print_expression ppf e;
     Format.fprintf ppf ")@]"

and print_switch_desc ppf = function
  { switch_subject = e; switch_cases = t_p_l_e_l; switch_default = e1; } ->
    Format.fprintf ppf "@[<1>{";
    Format.fprintf ppf "@[<1>switch_subject =@ "; print_expression ppf e;
    Format.fprintf ppf ";@]@ "; Format.fprintf ppf "@[<1>switch_cases =@ ";
    Lib_print.print_List
     ((fun ppf (p_l, e0) ->
        Format.fprintf ppf "@[<1>("; Format.fprintf ppf "@[<1>(";
        Lib_print.print_List print_pattern ppf p_l; Format.fprintf ppf ",@ ";
        print_expression ppf e0; Format.fprintf ppf ")@]";
        Format.fprintf ppf "@,)@]")
     ) ppf t_p_l_e_l;
    Format.fprintf ppf ";@]@ "; Format.fprintf ppf "@[<1>switch_default =@ ";
    print_expression ppf e1; Format.fprintf ppf ";@]@ ";
    Format.fprintf ppf "@,}@]"

and print_pattern = (fun ppf e -> print_expression ppf e)
;;

(* End of /usr/local/bin/ocamlprintc generated code *)
