(* Beginning of ocamlprintc-3.3+dev4 generated code *)

let rec print_expression ppf = function
  | Splice_ast.S_colon -> Format.fprintf ppf "%s" "S_colon"
  | Splice_ast.S_dollar -> Format.fprintf ppf "%s" "S_dollar"
  | Splice_ast.S_string s ->
    Format.fprintf ppf "@[<1>%s@ " "S_string";
    Lib_print.print_quoted_string ppf s; Format.fprintf ppf "%,@]"
  | Splice_ast.S_number s ->
    Format.fprintf ppf "@[<1>%s@ " "S_number";
    Lib_print.print_quoted_string ppf s; Format.fprintf ppf "%,@]"
  | Splice_ast.S_matrix e_l ->
    Format.fprintf ppf "@[<1>%s@ " "S_matrix";
    Lib_print.print_List print_expression ppf e_l; Format.fprintf ppf "%,@]"
  | Splice_ast.S_variable s ->
    Format.fprintf ppf "@[<1>%s@ " "S_variable";
    Lib_print.print_quoted_string ppf s; Format.fprintf ppf "%,@]"
  | Splice_ast.S_parameter i ->
    Format.fprintf ppf "@[<1>%s@ " "S_parameter";
    Lib_print.print_quoted_int ppf i; Format.fprintf ppf "%,@]"
  | Splice_ast.S_if (e, e0, e1) ->
    Format.fprintf ppf "@[<1>%s@ " "S_if"; Format.fprintf ppf "%,@[<1>(@,";
    print_expression ppf e; Format.fprintf ppf "%,,@ ";
    print_expression ppf e0; Format.fprintf ppf "%,,@ ";
    print_expression ppf e1; Format.fprintf ppf "%,@,)@]";
    Format.fprintf ppf "%,@]"
  | Splice_ast.S_unary (d_u, e) ->
    Format.fprintf ppf "@[<1>%s@ " "S_unary";
    Format.fprintf ppf "%,@[<1>(@,"; Deep_ast_print.print_unop ppf d_u;
    Format.fprintf ppf "%,,@ "; print_expression ppf e;
    Format.fprintf ppf "%,@,)@]"; Format.fprintf ppf "%,@]"
  | Splice_ast.S_binary (d_b, e, e0) ->
    Format.fprintf ppf "@[<1>%s@ " "S_binary";
    Format.fprintf ppf "%,@[<1>(@,"; Deep_ast_print.print_binop ppf d_b;
    Format.fprintf ppf "%,,@ "; print_expression ppf e;
    Format.fprintf ppf "%,,@ "; print_expression ppf e0;
    Format.fprintf ppf "%,@,)@]"; Format.fprintf ppf "%,@]"
  | Splice_ast.S_ternary (d_t, e, e0, e1) ->
    Format.fprintf ppf "@[<1>%s@ " "S_ternary";
    Format.fprintf ppf "%,@[<1>(@,"; Deep_ast_print.print_ternop ppf d_t;
    Format.fprintf ppf "%,,@ "; print_expression ppf e;
    Format.fprintf ppf "%,,@ "; print_expression ppf e0;
    Format.fprintf ppf "%,,@ "; print_expression ppf e1;
    Format.fprintf ppf "%,@,)@]"; Format.fprintf ppf "%,@]"
  | Splice_ast.S_quaternary (d_q, e, e0, e1, e2) ->
    Format.fprintf ppf "@[<1>%s@ " "S_quaternary";
    Format.fprintf ppf "%,@[<1>(@,"; Deep_ast_print.print_quaternop ppf d_q;
    Format.fprintf ppf "%,,@ "; print_expression ppf e;
    Format.fprintf ppf "%,,@ "; print_expression ppf e0;
    Format.fprintf ppf "%,,@ "; print_expression ppf e1;
    Format.fprintf ppf "%,,@ "; print_expression ppf e2;
    Format.fprintf ppf "%,@,)@]"; Format.fprintf ppf "%,@]"
  | Splice_ast.S_apply (e, e_l) ->
    Format.fprintf ppf "@[<1>%s@ " "S_apply";
    Format.fprintf ppf "%,@[<1>(@,"; print_expression ppf e;
    Format.fprintf ppf "%,,@ ";
    Lib_print.print_List print_expression ppf e_l;
    Format.fprintf ppf "%,@,)@]"; Format.fprintf ppf "%,@]"
  | Splice_ast.S_record_access (e, d_l) ->
    Format.fprintf ppf "@[<1>%s@ " "S_record_access";
    Format.fprintf ppf "%,@[<1>(@,"; print_expression ppf e;
    Format.fprintf ppf "%,,@ "; Deep_ast_print.print_label ppf d_l;
    Format.fprintf ppf "%,@,)@]"; Format.fprintf ppf "%,@]"
  | Splice_ast.S_paren e ->
    Format.fprintf ppf "@[<1>%s@ " "S_paren"; print_expression ppf e;
    Format.fprintf ppf "%,@]"
  | Splice_ast.S_bracket e ->
    Format.fprintf ppf "@[<1>%s@ " "S_bracket"; print_expression ppf e;
    Format.fprintf ppf "%,@]"
  | Splice_ast.S_splice e ->
    Format.fprintf ppf "@[<1>%s@ " "S_splice"; print_expression ppf e;
    Format.fprintf ppf "%,@]"
;;

(* End of ocamlprintc-3.3+dev4 generated code *)
