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

(* $Id: compile.ml 5138 2013-06-27 22:52:06Z weis $ *)

open Splice_ast;;
open Machine;;

let substitute s f =
  let b = Buffer.create (String.length s) in
  for i = 0 to String.length s - 1 do
    Buffer.add_string b (f s.[i])
  done;
  Buffer.contents b
;;

let rev_compile (globals, xglobals) =

  let enter_spliced_expr i e =
    Hashtbl.add globals e i;
    Hashtbl.add xglobals i e;
    i + 1 in
  let get_spliced_expr e =
    Hashtbl.find globals e in

  let float_of_string s =
    try Pervasives.float_of_string s with
    | Failure _ ->
      let cs =
        substitute s
          (function
           | 'd' -> "e"
           | 'D' -> "E"
           | c -> String.make 1 c) in
      Pervasives.float_of_string cs in

  let rec loop idx code = function
    | S_colon -> assert false
    | S_dollar -> assert false
    | S_string _ -> assert false
    | S_number n -> idx, Quote (float_of_string n) :: code
    | S_matrix _ -> assert false
    | S_parameter i -> idx, Get_param i :: code
    | S_variable _ as e ->
      idx, Get_global (get_spliced_expr e) :: code
    | S_if (_cond, _e1, _e2) -> assert false (*idx, code*)
    | S_unary (op, e) ->
      let idx, code = loop idx code e in
      idx, Unary op :: code
    | S_binary (op, e1, e2) ->
      let idx, code = loop idx code e1 in
      let idx, code = loop idx (Push :: code) e2 in
      idx, Binary op :: code
    | S_ternary (op, e1, e2, e3) ->
      let idx, code = loop idx code e1 in
      let idx, code = loop idx (Push :: code) e2 in
      let idx, code = loop idx (Push :: code) e3 in
      idx, Ternary op :: code
    | S_quaternary (op, e1, e2, e3, e4) ->
      let idx, code = loop idx code e1 in
      let idx, code = loop idx (Push :: code) e2 in
      let idx, code = loop idx (Push :: code) e3 in
      let idx, code = loop idx (Push :: code) e4 in
      idx, Quaternary op :: code
    | S_apply (_e_f, _e_args) ->
      assert false
    | S_record_access (_e_rec, _label) -> idx, code
    | S_paren e -> loop idx code e
    | S_bracket e -> loop idx code e
    | S_splice (S_number n) ->
      idx, Quote (float_of_string n) :: code
    | S_splice e ->
      let idx = enter_spliced_expr idx e in
      idx, Get_global idx :: code in

  loop 0 []
;;

let compile e =
  let globals, xglobals = Hashtbl.create 10, Hashtbl.create 10 in
  let idx, code = rev_compile (globals, xglobals) e in
  let globals =
    let rec loop accu i =
      if i < 0 then List.rev accu else
      loop (Hashtbl.find xglobals i :: accu) (i - 1) in
    Array.of_list (List.rev (loop [] (idx - 1))) in
  idx, globals, List.rev code
;;
