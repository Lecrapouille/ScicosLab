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

(* $Id: ast_pprint.mli 5138 2013-06-27 22:52:06Z weis $ *)

val pprint_expression : Format.formatter -> Ast.expression -> unit
;;
val pprint_command : Format.formatter -> Ast.command -> unit
;;
