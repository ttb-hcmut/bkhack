(* An example of program translation *)

(*
#load "quel.cma";;
*)
open Quel_sym
open Quel_o
open Quel_p

module LNil_pass(F:SymanticsL) = struct
  module X0 = struct
    type 'a from = 'a F.repr
    type 'a term = Unknown : 'a from -> 'a term
                 | Empty   : 'a list term
    let fwd x = Unknown x
    let rec bwd : type a. a term -> a from = function
      | Unknown x -> x
      | Empty     -> F.nil ()
  end
  open X0
  module X = Trans_def(X0)
  open X
  module IDelta = struct
    let nil () = Empty
    let (@%) x y = match x with
      | Empty -> y
      | Unknown x -> Unknown((F.(@%) x (bwd y)))
  end
end

module LNil(F:SymanticsL) = struct
  module OptM  = LNil_pass(F)
  include OL(OptM.X)(F)
  include OptM.IDelta
end

module TF1(S:SymanticsL) = struct
  open S
  (* nil in the left *)
  let t1 = observe @@ fun () ->
    nil () @% yield (int 1)

  (* nil in the right *)
  let t2 = observe @@ fun () ->
    yield (int 1) @% nil ()

end

let module M = TF1(LNil(PL)) in M.t1
(* - : int list LNil(Quel_p.PL).obs = "yield 1" *)

let module M = TF1(LNil(PL)) in M.t2
(* - : int list LNil(Quel_p.PL).obs = "yield 1 @ []" *)
