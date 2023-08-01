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

(* $Id: main_polish.ml 5138 2013-06-27 22:52:06Z weis $ *)

module Treat = Treat_polish;;

let usage () =
  prerr_endline "polish [ -s <\"string\"> | -c <filename> ]";
  exit 2
;;

let main () =
  let argv = Sys.argv in
  let argc = Array.length argv in
  if argc = 3
  then
    match argv.(1) with
    | "-s" -> Treat.treat_string argv.(2)
    | "-c" -> Treat.treat_file argv.(2)
    | opt ->
      prerr_endline (Printf.sprintf "Unknown option %s" opt); usage ()
  else
  if argc = 2 then Treat.treat_string argv.(1) else usage ()
;;

main ()
;;
