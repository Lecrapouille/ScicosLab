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

(* $Id: treat_polish.mli 4481 2011-09-16 16:01:33Z weis $ *)

type operator = string;;

val treat_file : string -> (string list * operator list);;
val treat_string : string -> (string list * operator list);;
