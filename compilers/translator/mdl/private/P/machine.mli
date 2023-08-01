open Deep_ast;;
(* For unop and binop *)

type instruction =
   | Quote of float
   | Push
   | Pop
   | Accu
   | Get_param of int
   | Get_global of int
   | Unary of unop
   | Binary of binop
   | Ternary of ternop
   | Quaternary of quaternop
;;

type code = instruction list;;
