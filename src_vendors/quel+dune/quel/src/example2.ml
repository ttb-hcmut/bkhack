(* Other examples *)
(*
#load "quel.cma";;
#load "schema1.cma";;
*)
open Schema1

module TF2(S:SYM_SCHEMA) = struct
  open S
  let orders = table ("orders", orders ())
  let products = table ("products", products ())

  (* a simple query *)
  let q1 =
    foreach (fun () -> products) (fun o ->
    yield o)

  (* with case statement *)
  let q2 = foreach (fun () -> orders) (fun x ->
      yield (order (oid x) (opid x) (if_ ((qty x) <% (int 10)) (fun () -> (int 0)) (fun () -> (int 100)))))

  (* illegal forms *)
  let q3 = yield (int 1)    (* q3 and q4 are not normal form; `yield` should have a record to translate an SQL query *)
  let q4 = foreach (fun () -> yield (int 1)) (fun x ->
      yield (x +% (int 1)))

  let run t = observe @@ fun () -> t
end


let _ = let module M = TF2(FixGenSQL) in
  print_endline @@ M.run @@ M.q1
(* SELECT x.* FROM orders AS x WHERE true *)

let _ = let module M = TF2(FixGenSQL) in
  print_endline @@ M.run @@ M.q2
(* SELECT x.oid AS oid, x.pid AS pid, (CASE WHEN x.qty < 10 THEN 0 ELSE 100 END) AS qty FROM orders AS x WHERE true *)

let _ = let module M = TF2(FixGenSQL) in
  print_endline @@ M.run @@ M.q3
(* Exception: Failure "Normalization limit exceeded". *)

let _ = let module M = TF2(FixGenSQL) in
  print_endline @@ M.run @@ M.q4
(* Exception: Failure "Normalization limit exceeded". *)
