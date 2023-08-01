(* Beginning of ocamlprintc-3.3+dev4 generated code *)

let print_operator ppf = function | s -> Lib_print.print_quoted_string ppf s
;;

let print_label ppf = function | s -> Lib_print.print_quoted_string ppf s
;;

let rec print_expression ppf = function
  | Ast.E_colon -> Format.fprintf ppf "%s" "E_colon"
  | Ast.E_dollar -> Format.fprintf ppf "%s" "E_dollar"
  | Ast.E_number s ->
    Format.fprintf ppf "@[<1>%s@ " "E_number";
    Lib_print.print_quoted_string ppf s; Format.fprintf ppf "%,@]"
  | Ast.E_string s ->
    Format.fprintf ppf "@[<1>%s@ " "E_string";
    Lib_print.print_quoted_string ppf s; Format.fprintf ppf "%,@]"
  | Ast.E_matrix e_l_l ->
    Format.fprintf ppf "@[<1>%s@ " "E_matrix";
    Lib_print.print_List (Lib_print.print_List print_expression) ppf e_l_l;
    Format.fprintf ppf "%,@]"
  | Ast.E_variable s ->
    Format.fprintf ppf "@[<1>%s@ " "E_variable";
    Lib_print.print_quoted_string ppf s; Format.fprintf ppf "%,@]"
  | Ast.E_parameter s ->
    Format.fprintf ppf "@[<1>%s@ " "E_parameter";
    Lib_print.print_quoted_string ppf s; Format.fprintf ppf "%,@]"
  | Ast.E_if (e, e0, e1) ->
    Format.fprintf ppf "@[<1>%s@ " "E_if"; Format.fprintf ppf "%,@[<1>(@,";
    print_expression ppf e; Format.fprintf ppf "%,,@ ";
    print_expression ppf e0; Format.fprintf ppf "%,,@ ";
    print_expression ppf e1; Format.fprintf ppf "%,@,)@]";
    Format.fprintf ppf "%,@]"
  | Ast.E_binary (o, e, e0) ->
    Format.fprintf ppf "@[<1>%s@ " "E_binary";
    Format.fprintf ppf "%,@[<1>(@,"; print_operator ppf o;
    Format.fprintf ppf "%,,@ "; print_expression ppf e;
    Format.fprintf ppf "%,,@ "; print_expression ppf e0;
    Format.fprintf ppf "%,@,)@]"; Format.fprintf ppf "%,@]"
  | Ast.E_unary (o, e) ->
    Format.fprintf ppf "@[<1>%s@ " "E_unary";
    Format.fprintf ppf "%,@[<1>(@,"; print_operator ppf o;
    Format.fprintf ppf "%,,@ "; print_expression ppf e;
    Format.fprintf ppf "%,@,)@]"; Format.fprintf ppf "%,@]"
  | Ast.E_apply (e, e_l) ->
    Format.fprintf ppf "@[<1>%s@ " "E_apply";
    Format.fprintf ppf "%,@[<1>(@,"; print_expression ppf e;
    Format.fprintf ppf "%,,@ ";
    Lib_print.print_List print_expression ppf e_l;
    Format.fprintf ppf "%,@,)@]"; Format.fprintf ppf "%,@]"
  | Ast.E_record_access (e, l) ->
    Format.fprintf ppf "@[<1>%s@ " "E_record_access";
    Format.fprintf ppf "%,@[<1>(@,"; print_expression ppf e;
    Format.fprintf ppf "%,,@ "; print_label ppf l;
    Format.fprintf ppf "%,@,)@]"; Format.fprintf ppf "%,@]"
  | Ast.E_switch s ->
    Format.fprintf ppf "@[<1>%s@ " "E_switch"; print_switch_desc ppf s;
    Format.fprintf ppf "%,@]"
  | Ast.E_bracket e ->
    Format.fprintf ppf "@[<1>%s@ " "E_bracket"; print_expression ppf e;
    Format.fprintf ppf "%,@]"
  | Ast.E_paren e ->
    Format.fprintf ppf "@[<1>%s@ " "E_paren"; print_expression ppf e;
    Format.fprintf ppf "%,@]"

and print_switch_desc ppf = function
  | {
      Ast.switch_subject = e;
      Ast.switch_cases = t_e_e_l;
      Ast.switch_default = e2;
    } ->
    Format.fprintf ppf "%,@[<1>{@,";
    Format.fprintf ppf "%,@[<1>switch_subject =@ "; print_expression ppf e;
    Format.fprintf ppf "%,;@]@ ";
    Format.fprintf ppf "%,@[<1>switch_cases =@ ";
    Lib_print.print_List
     ((fun ppf (e0, e1) ->
       Format.fprintf ppf "%,@[<1>(@,"; print_expression ppf e0;
       Format.fprintf ppf "%,,@ "; print_expression ppf e1;
       Format.fprintf ppf "%,@,)@]")
     ) ppf t_e_e_l;
    Format.fprintf ppf "%,;@]@ ";
    Format.fprintf ppf "%,@[<1>switch_default =@ "; print_expression ppf e2;
    Format.fprintf ppf "%,;@]@ "; Format.fprintf ppf "%,@,}@]"
;;

let rec print_command ppf = function
  | Ast.C_if (e, c, c0) ->
    Format.fprintf ppf "@[<1>%s@ " "C_if"; Format.fprintf ppf "%,@[<1>(@,";
    print_expression ppf e; Format.fprintf ppf "%,,@ "; print_command ppf c;
    Format.fprintf ppf "%,,@ "; print_command ppf c0;
    Format.fprintf ppf "%,@,)@]"; Format.fprintf ppf "%,@]"
  | Ast.C_paren c ->
    Format.fprintf ppf "@[<1>%s@ " "C_paren"; print_command ppf c;
    Format.fprintf ppf "%,@]"
;;

(* End of ocamlprintc-3.3+dev4 generated code *)
