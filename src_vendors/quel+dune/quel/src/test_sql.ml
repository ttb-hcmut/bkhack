(*
#load "quel.cma";;
*)

open Quel_sym
open Quel_sql

module TF1(S:SYM_SCHEMA) = struct
  open S
  let tbl = table ("example", orders ())
  let q1 = observe @@ fun () ->
    foreach (fun () -> tbl) (fun x ->
      yield x)

  let q2 = observe @@ fun () ->
    foreach (fun () -> yield (int 1) @% yield (int 2)) (fun x ->
        if_ (bool true) (fun () -> yield x) (fun () -> yield (x +% (int 2))))

end

let r = let module M = TF1(FixGenSQL) in M.q1



let r = let module M = TF1(GenSQL) in M.q2
