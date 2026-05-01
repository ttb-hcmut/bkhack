(* Extension of a set operation *)
(*
#load "quel.cma";;
*)
open Quel_sym
open Quel_r
open Quel_p
open Quel_o

(* Extend the SymanticsL *)
module type SymanticsS = sig
  include SymanticsL

  (* union *)
  val (@^) : 'a list repr -> 'a list repr -> 'a list repr
end

module TF1(S:SymanticsS) = struct
  open S
  let q1 = yield (int 1) @% yield (int 2) @% yield (int 3)
  let q2 = yield (int 1) @% yield (int 3) @% yield (int 4)
  let q3 = q1 @^ q2
end

(* Extend the RL interpreter *)
module RS = struct
  include RL
  type 'a top = 'a
  (* union *)
  let rec (@^) xs ys = List.fold_right (fun x l -> if List.mem x l then l else x::l) xs ys
end

let _ = let module M = TF1(RS) in M.q3
(* - : int list RS.repr = [2; 1; 3; 4] *)

(* Extend the PL interpreter *)
module PS = struct
  include PL
  let (@^) = print_infix 5 6 6 "@^"
end


(* Add new rule for Union *)
(* [ForUnion1]
   foreach (fun () -> L @^ M) (fun x () -> N)
   ---> foreach (fun () -> L)
                (fun x -> M)
        @^
        foreach (fun () -> L)
                (fun x -> N)
*)
module ForUnion1_pass(F:SymanticsS) = struct
  module X0 = struct
    type 'a from = 'a F.repr
    type 'a term =
      | Union    : ('a list term * 'a list term) -> 'a list term
      | Unknown  : 'a from -> 'a term
    let fwd x = Unknown x
    let rec bwd : type a. a term -> a from = function
      | Unknown x  -> x
      | Union(x,y) -> F.(@^) (bwd x) (bwd y)
  end
  open X0
  module X = Trans_def(X0)
  open X
  module IDelta = struct     (* function as a transform *)
    let (@^) e1 e2 = Union(e1, e2)
    let foreach src body =
      match src () with
      | Unknown x  -> fwd @@ F.foreach (fun () -> bwd @@ src ()) (fun x ->
                                 bwd @@ body (fwd x))
      | Union(x,y) -> fwd @@ F.(@^) (F.foreach (fun () -> bwd x) (fun x' ->
                                          bwd @@ body (fwd x')))
                                       (F.foreach (fun () -> bwd y) (fun y' ->
                                          bwd @@ body (fwd y')))
  end
end

module ForUnion1(F:SymanticsS) = struct
  module OptM  = ForUnion1_pass(F)
  include OL(OptM.X)(F)
  include OptM.IDelta       (* override *)
end


module TFO1(S:SymanticsS) = struct
  open S
  let src1 = yield (int 1) @% yield (int 2) @% yield (int 3)
  let src2 = yield (int 2) @% yield (int 4) @% yield (int 5)

  let q =
    observe @@ fun () ->
    foreach (fun () -> src1 @^ src2) (fun x ->
    yield x)
end

let _ =
  let r1 = let module M = TFO1(RS) in M.q in
  let r2 = let module M = TFO1(ForUnion1(RS)) in M.q in
  r1 = r2
(* - : bool = true *)

let _ = let module M = TFO1(ForUnion1(PS))
  in print_endline M.q
(*
  foreach (fun () -> yield 1 @ (yield 2 @ yield 3)) (fun x -> yield x) @^
  foreach (fun () -> yield 2 @ (yield 4 @ yield 5)) (fun x -> yield x)
*)
