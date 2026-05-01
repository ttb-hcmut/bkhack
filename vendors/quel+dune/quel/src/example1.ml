(* Examples *)

(*
#load "quel.cma";;
#load "schema1.cma";;
*)
open Schema1

module Q1(S:SYM_SCHEMA) = struct
  open S
  let table_orders = table ("orders", orders ())

  let res = lam (fun xoid ->
      foreach (fun () -> table_orders) @@ fun o ->
      where ((oid o) =% xoid) @@ fun () ->
      yield o)

  let observe = observe
end


module Q1_2(S:SYM_SCHEMA) = struct
  open S
  module M = Q1(S)
  let res = app (M.res) (int 2)

  let observe = observe
end


(* Auxiliary printers *)
let rec print_sale = function
  | [] -> ""
  | (o::os) -> "<pid=" ^ (string_of_int o#pid) ^
               ", name=" ^ o#name ^
               ", sale=" ^ (string_of_int o#sale) ^
               ">; " ^ print_sale os
;;

let rec print_order = function
  | [] -> ""
  | (o::os) -> "<oid=" ^ (string_of_int o#oid) ^
               ", pid=" ^ (string_of_int o#pid) ^
               ", qty=" ^ (string_of_int o#qty) ^
               ">; " ^ print_order os
;;

let module M = Q1_2(R) in
print_order @@ M.observe (fun () -> M.res)
(* "<oid=2, pid=5, qty=10>;
    <oid=2, pid=6, qty=20>; " *)


module Q1'(S:SYM_SCHEMA) = struct
  open S
  let table_orders = table ("orders", orders ())

  let res =
      foreach (fun () -> table_orders) @@ fun o ->
      where ((oid o) =% (int 2)) @@ fun () ->
      yield o

  let observe = observe
end

(* Q1' is in the normal form, and it is converted to the SQL query *)
let module M = Q1'(GenSQL) in M.observe (fun () -> M.res)
(* "SELECT x.* FROM orders AS x WHERE true AND x.oid = 2" *)



module Q2(S:SYM_SCHEMA) = struct
  open S
  let products = table ("products", products ())

  let res = lam (fun o ->
      foreach (fun () -> products) @@ fun p ->
      where ((pid p) =% (opid o)) @@ fun () ->
      yield @@ sales (pid p) (name p) ((price p) *% (qty o)))
end

module Q3(S:SYM_SCHEMA) = struct
  open S
  module M1 = Q1(S)
  module M2 = Q2(S)

  let q3 = lam (fun x ->
    foreach (fun () -> app M1.res x) @@ fun y ->
    app M2.res y)

  let res = app q3 (int 2)

  let observe = observe
end

let module M = Q3(R) in
 print_sale @@ M.observe (fun () -> M.res)

(* "<pid=5, name=HDD, sale=1000>;
    <pid=6, name=SDD, sale=10000>; " *)



(*--------------------------------------------------------------------*)
(* Normalizations *)

(* Q3 before the normalization *)
let _ = let module M = Q3(P) in
  print_endline @@ M.observe (fun () -> M.res)
(*
  (fun x ->
   foreach (fun () ->
     (fun y ->
        foreach (fun () -> table "orders") (fun z ->
          where (z.oid = y) (fun () -> yield z)))
        x)
     (fun y ->
     (fun z ->
        foreach (fun () -> table "products") (fun u ->
          where (u.pid = z.pid) (fun () ->
            yield <pid=(u.pid);name=(u.name);sale=(u.price * z.qty)>)))
        y))
   2
*)

(* Q3 after the normalization *)
let _ = let module M = Q3(FixP) in
  print_endline @@ M.observe (fun () -> M.res)
(*
  foreach (fun () -> table "orders") (fun x ->
  foreach (fun () -> table "products") (fun y ->
    where (x.oid = 2 && y.pid = x.pid) (fun () ->
      yield <pid=(y.pid);name=(y.name);sale=(y.price * x.qty)>)))
*)



(*--------------------------------------------------------------------*)
(* SQL translations *)


(* Generate SQL string *)
let _ = let module M = Q3(FixGenSQL)
  in M.observe (fun () -> M.res)
(* "SELECT y.pid AS pid, y.name AS name, y.price * x.qty AS sale
    FROM orders AS x, products AS y
    WHERE true AND x.oid = 2 AND y.pid = x.pid"

 pid | name | sale
-----+------+-------
   5 | HDD  |  1000
   6 | SSD  | 10000
*)


(*--------------------------------------------------------------------*)
(* Performance test; see also `example_tlinq.ml` *)

let avg l = (List.fold_left (+.) 0.0 l) /. float(List.length l)

let r =
  let module M = Q3(FixP) in
  let perform () : float =
    let s = Sys.time () in
    ignore (M.observe (fun () -> M.res));
    Sys.time () -. s
  in let rec loop (data:float list) = function
    | 0 -> data
    | n -> loop ((perform ())::data) (n-1)
  in loop [] 100
in avg r

(* AllPasses * 10 times:
- : float = 0.054658290000000005
       ---> 54.65829 milliseconds
       ---> 54658.29 microseconds
*)

(* MainPasses * 10 times:
- : float = 0.000944299999999999155
       ---> 0.9443 milliseconds
       ---> 944.3 microseconds
*)

let r =
  let module M = Q3(FixGenSQL) in
  let perform () : float =
    let s = Sys.time () in
    ignore (M.observe (fun () -> M.res));
    Sys.time () -. s
  in let rec loop (data:float list) = function
    | 0 -> data
    | n -> loop ((perform ())::data) (n-1)
  in loop [] 100
in avg r

(* AllPasses * 10 times:
- : float = 0.0579640699999997566
       ---> 57.96407 milliseconds
       ---> 57964.07 microseconds
*)

(* MainPasses * 10 times:
- : float = 0.000608050000000000495
       ---> 0.60805 milliseconds
       ---> 608.05  microseconds
*)

(* AllPasses * NF checking:
- : float = 0.00102530999999999586
       ---> 1.02531 milliseconds
       ---> 1025.31 microseconds
*)


(* MainPasses * NF checking:
- : float = 7.09399999999949e-05
       ---> 0.0000709399999999949
       ---> 0.070939999999995 milliseconds
       ---> 70.939999999995 microseconds
 *)
