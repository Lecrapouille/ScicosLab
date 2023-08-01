(* Beginning of ocamlprintc-3.3+dev4 generated code *)

open Deep_ast_print;;

let print_instruction ppf = function
  | Machine.Quote f ->
    Format.fprintf ppf "@[<1>%s@ " "Quote";
    Lib_print.print_quoted_float ppf f; Format.fprintf ppf "%,@]"
  | Machine.Push -> Format.fprintf ppf "%s" "Push"
  | Machine.Pop -> Format.fprintf ppf "%s" "Pop"
  | Machine.Accu -> Format.fprintf ppf "%s" "Accu"
  | Machine.Get_param i ->
    Format.fprintf ppf "@[<1>%s@ " "Get_param";
    Lib_print.print_quoted_int ppf i; Format.fprintf ppf "%,@]"
  | Machine.Get_global i ->
    Format.fprintf ppf "@[<1>%s@ " "Get_global";
    Lib_print.print_quoted_int ppf i; Format.fprintf ppf "%,@]"
  | Machine.Unary u ->
    Format.fprintf ppf "@[<1>%s@ " "Unary"; print_unop ppf u;
    Format.fprintf ppf "%,@]"
  | Machine.Binary b ->
    Format.fprintf ppf "@[<1>%s@ " "Binary"; print_binop ppf b;
    Format.fprintf ppf "%,@]"
  | Machine.Ternary t ->
    Format.fprintf ppf "@[<1>%s@ " "Ternary"; print_ternop ppf t;
    Format.fprintf ppf "%,@]"
  | Machine.Quaternary q ->
    Format.fprintf ppf "@[<1>%s@ " "Quaternary"; print_quaternop ppf q;
    Format.fprintf ppf "%,@]"
;;

let print_code ppf = function
  | i_l -> Lib_print.print_List print_instruction ppf i_l
;;

(* End of ocamlprintc-3.3+dev4 generated code *)
