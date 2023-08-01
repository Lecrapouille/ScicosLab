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

(* $Id: splice_ast_pprint.mli 4481 2011-09-16 16:01:33Z weis $ *)

val pprint: Format.formatter -> Splice_ast.expression -> unit;;
val pstring_of_spliced_expression: Splice_ast.expression -> string;;
