(*
#load "quel.cma";;
*)
open Quel_sym
open Quel_p

(* primitive & operators *)
module TF1(S:Symantics) = struct
  open S
  let t1 = observe @@ fun () -> (int 1) +% (int 2)
  let t2 = observe @@ fun () -> (bool false) |% (bool true)
  let t3 = observe @@ fun () ->
    if_ (bool true) (fun () ->
        if_ (bool false) (fun () -> (int 1) +% (int 2)) (fun () -> (int 0)))
      (fun () -> (int 100))
end

let r = let module M = TF1(P) in M.t1
let r = let module M = TF1(P) in M.t2
let r = let module M = TF1(P) in M.t3

(* lam app if *)

module TF2(S:SymanticsL) = struct
  open S
  let src = yield (int 1) @% yield (int 2) @% yield (int 3)

  let q1 = observe @@ fun () ->
    foreach (fun () -> src) (fun x ->
      where (bool true) (fun () ->
        yield x))

  let q2 = observe @@ fun () ->
    foreach (fun () ->
        foreach (fun () -> src) (fun x ->
        yield x)) (fun y ->
    foreach (fun () -> src) (fun z ->
    foreach (fun () -> src) (fun z ->
        yield z)))

  let products = []
  let q3 = observe @@ fun () ->
    foreach (fun () -> table ("products", products)) (fun x ->
      yield x)
end

let r = let module M = TF2(PL) in M.q1 in
print_string r

let r = let module M = TF2(PL) in M.q2 in
print_string r

let r = let module M = TF2(PL) in M.q3 in
print_string r
