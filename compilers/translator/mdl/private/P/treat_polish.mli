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

(* $Id: treat_polish.mli 5138 2013-06-27 22:52:06Z weis $ *)

type operator = string;;

val treat_file : string -> (string list * operator list);;
val treat_string : string -> (string list * operator list);;
