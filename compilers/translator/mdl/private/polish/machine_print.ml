(* Beginning of ocamlprintc generated code *)

open Machine;;

open Deep_ast;;

open Deep_ast_print;;

(* For unop and binop *)


let rec print_instruction ppf = function
  | Quote f ->
     Format.fprintf ppf "@[<1>(%s@ " "Quote";
     Lib_print.print_quoted_float ppf f; Format.fprintf ppf ")@]"
  | Push -> Format.fprintf ppf "Push" | Pop -> Format.fprintf ppf "Pop"
  | Accu -> Format.fprintf ppf "Accu"
  | Get_param i ->
     Format.fprintf ppf "@[<1>(%s@ " "Get_param";
     Lib_print.print_quoted_int ppf i; Format.fprintf ppf ")@]"
  | Get_global i ->
     Format.fprintf ppf "@[<1>(%s@ " "Get_global";
     Lib_print.print_quoted_int ppf i; Format.fprintf ppf ")@]"
  | Unary u ->
     Format.fprintf ppf "@[<1>(%s@ " "Unary"; print_unop ppf u;
     Format.fprintf ppf ")@]"
  | Binary b ->
     Format.fprintf ppf "@[<1>(%s@ " "Binary"; print_binop ppf b;
     Format.fprintf ppf ")@]"
  | Ternary t ->
     Format.fprintf ppf "@[<1>(%s@ " "Ternary"; print_ternop ppf t;
     Format.fprintf ppf ")@]"
  | Quaternary q ->
     Format.fprintf ppf "@[<1>(%s@ " "Quaternary"; print_quaternop ppf q;
     Format.fprintf ppf ")@]"
;;

let rec print_code =
  (fun ppf i_l -> Lib_print.print_List print_instruction ppf i_l)
;;

(* End of /usr/local/bin/ocamlprintc generated code *)
