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

(* $Id: splice_ast.mli 4846 2013-04-30 17:53:18Z weis $ *)

type expression =
   | S_colon
   | S_dollar
   | S_string of string
   | S_number of string
   | S_matrix of expression list
   | S_variable of string
   | S_parameter of int
   | S_if of expression * expression * expression
   | S_unary of Deep_ast.unop * expression
   | S_binary of Deep_ast.binop * expression * expression
   | S_ternary of Deep_ast.ternop * expression * expression * expression
   | S_quaternary of
       Deep_ast.quaternop * expression * expression * expression * expression
   | S_apply of expression * expression list
   | S_record_access of expression * Deep_ast.label
   | S_paren of expression
   | S_bracket of expression
   | S_splice of expression
;;
