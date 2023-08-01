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

(* $Id: print_polish.ml 4481 2011-09-16 16:01:33Z weis $ *)

open Format;;

let rec print ppf = function
  | accu_args, accu_ops ->
    fprintf ppf "@[<v>args_stack =@ %a,@ ops_stack =@ %a@]"
       print_accu_args accu_args
       print_accu_ops accu_ops

and print_accu_args ppf args =
  let print_args ppf l = List.iter (fun arg -> fprintf ppf "%s;@ " arg) l in
  fprintf ppf "@[<v>%a@]" print_args args

and print_accu_ops ppf = print_accu_args ppf
;;
