open Splice_ast;;
open Machine;;

(*
e1, e2, e3 ==> Bhconc (Bhconc (e1, e2), e3)
e1; e2; e3 ==> Bvconc (Bvconc (e1, e2), e3)

Switch (se1, [(ce1, e1); (ce2, e2); ... (cen, en); e_default]) ->
Compute the size of the result
  if match (se1 ce1) then add_to_result e1 else
  if match (se1 ce2) then add_to_result e2 else
  ...
  else add_to_result e_default
*)

let rec condition_switch e (cl, cls) =
  e, (cl, cls)
;;

let rec condition_matrix lines =
  match lines with
  | [] -> assert false
  | line :: lines ->
    Ulist1.foldl
      (fun cline1 cline2 ->
       S_binary (Deep_ast.Bvconc, cline1, cline2)
      )
      (condition_line line, List.map condition_line lines)

and condition_line line =
  match line with
  | [] -> assert false
  | col :: columns ->
    Ulist1.foldl
      (fun col1 col2 ->
       S_binary (Deep_ast.Bhconc, col1, col2)
      )
      (col, columns)
;;

let substitute s f =
  let b = Buffer.create (String.length s) in
  for i = 0 to String.length s - 1 do
    Buffer.add_string b (f s.[i])
  done;
  Buffer.contents b
;;

let rec multi_push code = function
  | 0 -> code
  | n -> multi_push (Push :: code) (n - 1)
;;

let rev_compile (globals, xglobals) =

  let enter_spliced_expr i e =
    let e = Splicing.fully_un_splice e in
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
    | S_number n -> idx, Quote (float_of_string n) :: code
    | S_string _ -> assert false
    | S_matrix lines -> loop idx code (condition_matrix lines)
    | S_parameter i -> idx, Get_param i :: code
    | S_variable _ as e ->
      idx, Get_global (get_spliced_expr e) :: code
    | S_if (e1, e2, e3) ->
      let idx, code = loop idx code e1 in
      let idx, code = loop idx (Push :: code) e2 in
      let idx, code = loop idx (Push :: code) e3 in
      idx, Ternary Deep_ast.Tdotif :: code
    | S_switch  {
        sswitch_subject = e;
        sswitch_cases = cls;
        sswitch_default = d;
      } ->
      let ncls = List.length cls in

      let idx, code = loop idx code e in
      let idx, code =
        idx, multi_push code (ncls - 1) in

      let idx, code = loop idx (Push :: code) d in

      List.fold_left
        (fun (idx, code) (pats, eci) ->
         match pats with
         | [ pat ] ->
           let idx, code = loop idx (Push :: code) eci in
           let idx, code = loop idx (Push :: code) pat in
           idx, Quaternary Deep_ast.Qdotswitchcase :: code
         | _ -> assert false)
        (idx, code)
        (List.rev cls)
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
  let globals, xglobals =
    Hashtbl.create 10, Hashtbl.create 10 in
  let idx, code = rev_compile (globals, xglobals) e in
  let globals =
    let rec loop accu i =
      if i < 0 then List.rev accu else
      loop (Hashtbl.find xglobals i :: accu) (i - 1) in
    Array.of_list (List.rev (loop [] (idx - 1))) in
  idx, globals, List.rev code
;;
