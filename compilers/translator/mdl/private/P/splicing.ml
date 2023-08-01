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

(* $Id: splicing.ml 4846 2013-04-30 17:53:18Z weis $ *)

open Deep_ast;;
open Splice_ast;;

let un_splice exp =
  match exp with
  | S_splice exp -> exp
  | S_colon | S_dollar
  | S_paren _ | S_bracket _ | S_record_access (_, _) | S_apply (_, _)
  | S_unary (_, _) | S_binary (_, _, _)
  | S_ternary (_, _, _, _) | S_quaternary (_, _, _, _, _)
  | S_if (_, _, _)
  | S_parameter _ | S_variable _ | S_string _ | S_number _ | S_matrix _ ->
    assert false
;;

let is_spliced exp =
  match exp with
  | S_splice _ -> true
  | S_paren _ | S_bracket _ | S_record_access (_, _)
  | S_apply (_, _)
  | S_binary (_, _, _) | S_unary (_, _)
  | S_quaternary (_, _, _, _, _) | S_ternary (_, _, _, _)
  | S_if (_, _, _)
  | S_parameter _ | S_variable _ | S_string _ | S_number _ | S_matrix _
  | S_dollar | S_colon -> false
;;

let splice_extract e_f e_args =
  match e_args with
  | [] -> assert false
  | [ e_arg; ] ->
    S_binary (Bextract, e_f, e_arg)
  | [ e_arg1; e_arg2; ] ->
    S_ternary (Textract, e_f, e_arg1, e_arg2)
  | _ ->
    failwith "Unsupported function application"
;;

let rec full_un_splice exp =
  match exp with
  | S_splice exp -> exp
  | S_colon | S_dollar -> exp
  | S_paren e -> S_paren (full_un_splice e)
  | S_bracket e -> S_bracket (full_un_splice e)
  | S_record_access (e1, e2) -> S_record_access (full_un_splice e1, e2)
  | S_apply (e1, e2) ->
    S_apply (full_un_splice e1, List.map full_un_splice e2)
  | S_unary (e1, e2) ->
    S_unary (e1, full_un_splice e2)
  | S_binary (e1, e2, e3) ->
    S_binary (e1, full_un_splice e2, full_un_splice e3)
  | S_ternary (e1, e2, e3, e4) ->
    S_ternary (e1, full_un_splice e2, full_un_splice e3, full_un_splice e4)
  | S_quaternary (e1, e2, e3, e4, e5) ->
    S_quaternary (
      e1, full_un_splice e2, full_un_splice e3,
      full_un_splice e4, full_un_splice e5)
  | S_if (e1, e2, e3) ->
    S_if (full_un_splice e1, full_un_splice e2, full_un_splice e3)
  | S_parameter _
  | S_variable _
  | S_string _
  | S_number _ -> exp
  | S_matrix exps -> S_matrix (List.map full_un_splice exps)
;;

let rec splice exp =
  match exp with
  | D_dollar -> S_splice S_dollar
  | D_colon -> S_splice S_colon
  | D_string s -> S_splice (S_string s)
  | D_number n -> S_splice (S_number n)
  | D_matrix _e_elems -> assert false
(*
    let e_elems = List.map splice e_elems in
    if List.for_all is_spliced e_elems
      then S_splice (S_matrix (List.map un_splice e_elems))
    else S_matrix (e_elems)
*)
  | D_variable v -> S_splice (S_variable v)
  | D_parameter i -> S_parameter i
  | D_accu e ->
    let e = splice e in
    if is_spliced e then S_splice (un_splice e) else S_splice e
  | D_if (cond, e_then, e_else) ->
    let cond, e_then, e_else =
      splice cond, splice e_then, splice e_else in
    if is_spliced cond && is_spliced e_then && is_spliced e_else
    then S_splice (S_if (un_splice cond, un_splice e_then, un_splice e_else))
    else S_if (cond, e_then, e_else)
  | D_unary ((Usizeprod | Usizerow | Usizecol as op), e) ->
    let e = splice e in
    if is_spliced e
    then S_splice (S_unary (op, un_splice e))
    else S_splice (S_unary (op, full_un_splice e))
  | D_unary (op, x) ->
    let x = splice x in
    if is_spliced x
    then S_splice (S_unary (op, un_splice x))
    else S_unary (op, x)
  | D_binary (op, x, y) ->
    let x = splice x and y = splice y in
    if is_spliced x && is_spliced y
    then S_splice (S_binary (op, un_splice x, un_splice y))
    else S_binary (op, x, y)
  | D_ternary (op, x, y, z) ->
    let x = splice x and y = splice y and z = splice z in
    if is_spliced x && is_spliced y && is_spliced z
    then S_splice (S_ternary (op, un_splice x, un_splice y, un_splice z))
    else S_ternary (op, x, y, z)
  | D_quaternary (op, x, y, z, t) ->
    let x = splice x and y = splice y
    and z = splice z and t = splice t in
    if is_spliced x && is_spliced y && is_spliced z && is_spliced t
    then S_splice
           (S_quaternary
              (op, un_splice x, un_splice y, un_splice z, un_splice t))
    else S_quaternary (op, x, y, z, t)
  | D_apply (e_f, e_args) ->
    let e_f = splice e_f
    and e_args = List.map splice e_args in
    if is_spliced e_f && List.for_all is_spliced e_args
      then S_splice (S_apply (un_splice e_f, List.map un_splice e_args))
    else splice_extract e_f e_args
  | D_record_access (e, label) ->
    let e = splice e in
    if is_spliced e
    then S_splice (S_record_access (un_splice e, label))
    else S_record_access (e, label)
  | D_switch _ -> assert false
  | D_bracket e ->
    let e = splice e in
    if is_spliced e
    then S_splice (S_bracket (un_splice e))
    else S_bracket e
  | D_paren e ->
    let e = splice e in
    if is_spliced e
    then S_splice (S_paren (un_splice e))
    else S_paren e
;;
