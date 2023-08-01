(* Beginning of ocamlprintc-3.3+dev4 generated code *)

let print_unop ppf = function
  | Deep_ast.Uabs -> Format.fprintf ppf "%s" "Uabs"
  | Deep_ast.Uacos -> Format.fprintf ppf "%s" "Uacos"
  | Deep_ast.Uacosh -> Format.fprintf ppf "%s" "Uacosh"
  | Deep_ast.Uasin -> Format.fprintf ppf "%s" "Uasin"
  | Deep_ast.Uasinh -> Format.fprintf ppf "%s" "Uasinh"
  | Deep_ast.Uatan -> Format.fprintf ppf "%s" "Uatan"
  | Deep_ast.Uatanh -> Format.fprintf ppf "%s" "Uatanh"
  | Deep_ast.Uceil -> Format.fprintf ppf "%s" "Uceil"
  | Deep_ast.Ucolon -> Format.fprintf ppf "%s" "Ucolon"
  | Deep_ast.Ucos -> Format.fprintf ppf "%s" "Ucos"
  | Deep_ast.Ucosh -> Format.fprintf ppf "%s" "Ucosh"
  | Deep_ast.Uexp -> Format.fprintf ppf "%s" "Uexp"
  | Deep_ast.Uexpm -> Format.fprintf ppf "%s" "Uexpm"
  | Deep_ast.Ufloor -> Format.fprintf ppf "%s" "Ufloor"
  | Deep_ast.Uint -> Format.fprintf ppf "%s" "Uint"
  | Deep_ast.Uinv -> Format.fprintf ppf "%s" "Uinv"
  | Deep_ast.Ulog -> Format.fprintf ppf "%s" "Ulog"
  | Deep_ast.Ulog10 -> Format.fprintf ppf "%s" "Ulog10"
  | Deep_ast.Ulogm -> Format.fprintf ppf "%s" "Ulogm"
  | Deep_ast.Uminus -> Format.fprintf ppf "%s" "Uminus"
  | Deep_ast.Unot -> Format.fprintf ppf "%s" "Unot"
  | Deep_ast.Ureshape -> Format.fprintf ppf "%s" "Ureshape"
  | Deep_ast.Uround -> Format.fprintf ppf "%s" "Uround"
  | Deep_ast.Usign -> Format.fprintf ppf "%s" "Usign"
  | Deep_ast.Usin -> Format.fprintf ppf "%s" "Usin"
  | Deep_ast.Usinh -> Format.fprintf ppf "%s" "Usinh"
  | Deep_ast.Usizeprod -> Format.fprintf ppf "%s" "Usizeprod"
  | Deep_ast.Usizecol -> Format.fprintf ppf "%s" "Usizecol"
  | Deep_ast.Usizerow -> Format.fprintf ppf "%s" "Usizerow"
  | Deep_ast.Usum -> Format.fprintf ppf "%s" "Usum"
  | Deep_ast.Usumcol -> Format.fprintf ppf "%s" "Usumcol"
  | Deep_ast.Usumrow -> Format.fprintf ppf "%s" "Usumrow"
  | Deep_ast.Utranspose -> Format.fprintf ppf "%s" "Utranspose"
  | Deep_ast.Uctranspose -> Format.fprintf ppf "%s" "Uctranspose"
  | Deep_ast.Usqrt -> Format.fprintf ppf "%s" "Usqrt"
  | Deep_ast.Utan -> Format.fprintf ppf "%s" "Utan"
  | Deep_ast.Utanh -> Format.fprintf ppf "%s" "Utanh"
  | Deep_ast.Ueye -> Format.fprintf ppf "%s" "Ueye"
;;

let print_binop ppf = function
  | Deep_ast.Badd -> Format.fprintf ppf "%s" "Badd"
  | Deep_ast.Bsub -> Format.fprintf ppf "%s" "Bsub"
  | Deep_ast.Bmul -> Format.fprintf ppf "%s" "Bmul"
  | Deep_ast.Bdiv -> Format.fprintf ppf "%s" "Bdiv"
  | Deep_ast.Bexp -> Format.fprintf ppf "%s" "Bexp"
  | Deep_ast.Bldiv -> Format.fprintf ppf "%s" "Bldiv"
  | Deep_ast.Beq -> Format.fprintf ppf "%s" "Beq"
  | Deep_ast.Blt -> Format.fprintf ppf "%s" "Blt"
  | Deep_ast.Bgt -> Format.fprintf ppf "%s" "Bgt"
  | Deep_ast.Ble -> Format.fprintf ppf "%s" "Ble"
  | Deep_ast.Bge -> Format.fprintf ppf "%s" "Bge"
  | Deep_ast.Bne -> Format.fprintf ppf "%s" "Bne"
  | Deep_ast.Blor -> Format.fprintf ppf "%s" "Blor"
  | Deep_ast.Bland -> Format.fprintf ppf "%s" "Bland"
  | Deep_ast.Blne -> Format.fprintf ppf "%s" "Blne"
  | Deep_ast.Bmin -> Format.fprintf ppf "%s" "Bmin"
  | Deep_ast.Bmax -> Format.fprintf ppf "%s" "Bmax"
  | Deep_ast.Batan2 -> Format.fprintf ppf "%s" "Batan2"
  | Deep_ast.Bmulm -> Format.fprintf ppf "%s" "Bmulm"
  | Deep_ast.Bdivm -> Format.fprintf ppf "%s" "Bdivm"
  | Deep_ast.Bldivm -> Format.fprintf ppf "%s" "Bldivm"
  | Deep_ast.Bexpm -> Format.fprintf ppf "%s" "Bexpm"
  | Deep_ast.Bhconc -> Format.fprintf ppf "%s" "Bhconc"
  | Deep_ast.Bvconc -> Format.fprintf ppf "%s" "Bvconc"
  | Deep_ast.Bextract -> Format.fprintf ppf "%s" "Bextract"
  | Deep_ast.Bextract_all_columns ->
    Format.fprintf ppf "%s" "Bextract_all_columns"
  | Deep_ast.Bextract_all_rows -> Format.fprintf ppf "%s" "Bextract_all_rows"
  | Deep_ast.Bremove -> Format.fprintf ppf "%s" "Bremove"
  | Deep_ast.Bremove_all_columns ->
    Format.fprintf ppf "%s" "Bremove_all_columns"
  | Deep_ast.Bremove_all_rows -> Format.fprintf ppf "%s" "Bremove_all_rows"
  | Deep_ast.Brange -> Format.fprintf ppf "%s" "Brange"
  | Deep_ast.Bassign -> Format.fprintf ppf "%s" "Bassign"
  | Deep_ast.Bones -> Format.fprintf ppf "%s" "Bones"
  | Deep_ast.Bzeros -> Format.fprintf ppf "%s" "Bzeros"
;;

let print_ternop ppf = function
  | Deep_ast.Textract -> Format.fprintf ppf "%s" "Textract"
  | Deep_ast.Trange -> Format.fprintf ppf "%s" "Trange"
  | Deep_ast.Tassign -> Format.fprintf ppf "%s" "Tassign"
  | Deep_ast.Tassign_all_columns ->
    Format.fprintf ppf "%s" "Tassign_all_columns"
  | Deep_ast.Tassign_all_rows -> Format.fprintf ppf "%s" "Tassign_all_rows"
;;

let print_quaternop ppf = function
  | Deep_ast.Qassign -> Format.fprintf ppf "%s" "Qassign"
;;

let print_label ppf = function | s -> Lib_print.print_quoted_string ppf s
;;

let rec print_expression ppf = function
  | Deep_ast.D_colon -> Format.fprintf ppf "%s" "D_colon"
  | Deep_ast.D_dollar -> Format.fprintf ppf "%s" "D_dollar"
  | Deep_ast.D_number s ->
    Format.fprintf ppf "@[<1>%s@ " "D_number";
    Lib_print.print_quoted_string ppf s; Format.fprintf ppf "%,@]"
  | Deep_ast.D_string s ->
    Format.fprintf ppf "@[<1>%s@ " "D_string";
    Lib_print.print_quoted_string ppf s; Format.fprintf ppf "%,@]"
  | Deep_ast.D_matrix e_l_l ->
    Format.fprintf ppf "@[<1>%s@ " "D_matrix";
    Lib_print.print_List (Lib_print.print_List print_expression) ppf e_l_l;
    Format.fprintf ppf "%,@]"
  | Deep_ast.D_variable s ->
    Format.fprintf ppf "@[<1>%s@ " "D_variable";
    Lib_print.print_quoted_string ppf s; Format.fprintf ppf "%,@]"
  | Deep_ast.D_parameter i ->
    Format.fprintf ppf "@[<1>%s@ " "D_parameter";
    Lib_print.print_quoted_int ppf i; Format.fprintf ppf "%,@]"
  | Deep_ast.D_accu e ->
    Format.fprintf ppf "@[<1>%s@ " "D_accu"; print_expression ppf e;
    Format.fprintf ppf "%,@]"
  | Deep_ast.D_if (e, e0, e1) ->
    Format.fprintf ppf "@[<1>%s@ " "D_if"; Format.fprintf ppf "%,@[<1>(@,";
    print_expression ppf e; Format.fprintf ppf "%,,@ ";
    print_expression ppf e0; Format.fprintf ppf "%,,@ ";
    print_expression ppf e1; Format.fprintf ppf "%,@,)@]";
    Format.fprintf ppf "%,@]"
  | Deep_ast.D_unary (u, e) ->
    Format.fprintf ppf "@[<1>%s@ " "D_unary";
    Format.fprintf ppf "%,@[<1>(@,"; print_unop ppf u;
    Format.fprintf ppf "%,,@ "; print_expression ppf e;
    Format.fprintf ppf "%,@,)@]"; Format.fprintf ppf "%,@]"
  | Deep_ast.D_binary (b, e, e0) ->
    Format.fprintf ppf "@[<1>%s@ " "D_binary";
    Format.fprintf ppf "%,@[<1>(@,"; print_binop ppf b;
    Format.fprintf ppf "%,,@ "; print_expression ppf e;
    Format.fprintf ppf "%,,@ "; print_expression ppf e0;
    Format.fprintf ppf "%,@,)@]"; Format.fprintf ppf "%,@]"
  | Deep_ast.D_ternary (t, e, e0, e1) ->
    Format.fprintf ppf "@[<1>%s@ " "D_ternary";
    Format.fprintf ppf "%,@[<1>(@,"; print_ternop ppf t;
    Format.fprintf ppf "%,,@ "; print_expression ppf e;
    Format.fprintf ppf "%,,@ "; print_expression ppf e0;
    Format.fprintf ppf "%,,@ "; print_expression ppf e1;
    Format.fprintf ppf "%,@,)@]"; Format.fprintf ppf "%,@]"
  | Deep_ast.D_quaternary (q, e, e0, e1, e2) ->
    Format.fprintf ppf "@[<1>%s@ " "D_quaternary";
    Format.fprintf ppf "%,@[<1>(@,"; print_quaternop ppf q;
    Format.fprintf ppf "%,,@ "; print_expression ppf e;
    Format.fprintf ppf "%,,@ "; print_expression ppf e0;
    Format.fprintf ppf "%,,@ "; print_expression ppf e1;
    Format.fprintf ppf "%,,@ "; print_expression ppf e2;
    Format.fprintf ppf "%,@,)@]"; Format.fprintf ppf "%,@]"
  | Deep_ast.D_apply (e, e_l) ->
    Format.fprintf ppf "@[<1>%s@ " "D_apply";
    Format.fprintf ppf "%,@[<1>(@,"; print_expression ppf e;
    Format.fprintf ppf "%,,@ ";
    Lib_print.print_List print_expression ppf e_l;
    Format.fprintf ppf "%,@,)@]"; Format.fprintf ppf "%,@]"
  | Deep_ast.D_record_access (e, l) ->
    Format.fprintf ppf "@[<1>%s@ " "D_record_access";
    Format.fprintf ppf "%,@[<1>(@,"; print_expression ppf e;
    Format.fprintf ppf "%,,@ "; print_label ppf l;
    Format.fprintf ppf "%,@,)@]"; Format.fprintf ppf "%,@]"
  | Deep_ast.D_switch s ->
    Format.fprintf ppf "@[<1>%s@ " "D_switch"; print_switch_desc ppf s;
    Format.fprintf ppf "%,@]"
  | Deep_ast.D_bracket e ->
    Format.fprintf ppf "@[<1>%s@ " "D_bracket"; print_expression ppf e;
    Format.fprintf ppf "%,@]"
  | Deep_ast.D_paren e ->
    Format.fprintf ppf "@[<1>%s@ " "D_paren"; print_expression ppf e;
    Format.fprintf ppf "%,@]"

and print_switch_desc ppf = function
  | {
      Deep_ast.dswitch_subject = e;
      Deep_ast.dswitch_cases = t_e_e_l;
      Deep_ast.dswitch_default = e2;
    } ->
    Format.fprintf ppf "%,@[<1>{@,";
    Format.fprintf ppf "%,@[<1>dswitch_subject =@ "; print_expression ppf e;
    Format.fprintf ppf "%,;@]@ ";
    Format.fprintf ppf "%,@[<1>dswitch_cases =@ ";
    Lib_print.print_List
     ((fun ppf (e0, e1) ->
       Format.fprintf ppf "%,@[<1>(@,"; print_expression ppf e0;
       Format.fprintf ppf "%,,@ "; print_expression ppf e1;
       Format.fprintf ppf "%,@,)@]")
     ) ppf t_e_e_l;
    Format.fprintf ppf "%,;@]@ ";
    Format.fprintf ppf "%,@[<1>dswitch_default =@ "; print_expression ppf e2;
    Format.fprintf ppf "%,;@]@ "; Format.fprintf ppf "%,@,}@]"
;;

(* End of ocamlprintc-3.3+dev4 generated code *)
