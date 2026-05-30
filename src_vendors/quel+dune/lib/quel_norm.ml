open Quel_sym
open Quel_o

(* Normalization rules by Cheney et al. (2013) *)

(* We define optimization passes that will override OL with
   optimization-specific transformations.

   The following functor is the container for two modules: X describes
   the reflection/reification and IDelta describes the optimizations
   themselves, as interpretations of only those expression forms
   the DSL that are affected by this particular optimization.
*)

(*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  Stage 1
  \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
*)

(* --------------------------------------
   [AbsBeta]
   (\x.M) N ---> N[x := M]
   ------------------------------------*)
module AbsBeta_pass(F:SymanticsL) = struct
  module X0 = struct
    type 'a from = 'a F.repr
    type 'a term = Unknown : 'a from -> 'a term
	         | Lam     : ('a term -> 'b term) -> ('a -> 'b) term
    let fwd x = Unknown x                              (* generic reflection *)
    let rec bwd : type a. a term -> a from = function  (* reification *)
      | Unknown e -> e
      | Lam f     -> F.lam (fun x -> bwd (f (fwd x)))
  end
  open X0
  module X = Trans_def(X0)
  open X
  (* optimization *)
  module IDelta = struct
    let lam f = Lam f
    let app e1 e2 =
      match e1 with
      | Lam f -> f e2
      | _ -> fmap2 F.app e1 e2
  end
end

(* Combine the concrete optimization with the default optimizer *)
module AbsBeta(F:SymanticsL) = struct
  module M = AbsBeta_pass(F)
  include OL(M.X)(F)        (* the default optimizer *)
  include M.IDelta          (* overriding `lam` and `app` *)
end


(* --------------------------------------
   [RecordBeta]
   <l_1=M_1,...,l_n=M_n>.l_i ---> M_i
   See `schema1.ml` file
   ------------------------------------*)


(* --------------------------------------
   [ForYield]
   foreach (fun () -> yield M) (fun x -> N)
   ---> N[x := M]
   ------------------------------------*)
module ForYield_pass(F:SymanticsL) = struct
  module X0 = struct
    type 'a from = 'a F.repr
    type 'a term = Unknown : 'a from -> 'a term
	         | Yield   : 'a term -> 'a list term
    let fwd x = Unknown x
    let rec bwd : type a. a term -> a from = function
      | Unknown e -> e
      | Yield e   -> F.yield (bwd e)
  end
  open X0
  module X = Trans_def(X0)
  open X
  module IDelta = struct
    let yield e = Yield e
    let foreach src body =
      match src () with
      | Yield e -> (body e)
      | _       -> fwd @@ F.foreach (fun () ->
                          bwd (src ())) (fun x ->
                          bwd (body (fwd x)))
  end
end

(* Combine the optimization with the base interpreter *)
module ForYield(F:SymanticsL) = struct
  module M = ForYield_pass(F)
  include OL(M.X)(F)
  include M.IDelta          (* overriding *)
end

(* --------------------------------------
   [ForFor]
   foreach (fun () -> yield M) (fun x -> N)
   ---> N[x := M]
   ------------------------------------*)
module ForFor_pass(F:SymanticsL) = struct
  module X0 = struct
    type 'a from = 'a F.repr
    type 'a term =
      | Unknown : 'a from -> 'a term
      | For     : (unit -> 'a list term) * ('a term -> 'b list term) -> 'b list term

    let fwd x = Unknown x
    let rec bwd : type a. a term -> a from = function
      | Unknown e -> e
      | For (s,b) -> F.foreach (fun () -> bwd @@ s ()) (fun x ->
          bwd @@ b (fwd x))
  end
  open X0
  module X = Trans_def(X0)
  open X
  module IDelta = struct
    let foreach src body =
      match src () with
      | Unknown e -> For (src, body)
      | For (s,b) -> fwd @@ F.foreach (fun () -> bwd @@ s ()) (fun x ->
                            F.foreach (fun () -> bwd @@ b (fwd x)) (fun y ->
                            bwd @@ body (fwd y)))
  end
end

module ForFor(F:SymanticsL) = struct
  module M = ForFor_pass(F)
  include OL(M.X)(F)
  include M.IDelta
end


(* [ForWhere]
   foreach (fun () ->
   where L (fun () -> M) (fun x -> N)
   ---> where L (fun () ->
        foreach (fun () -> M) (fun x -> N))
 *)
module ForWhere_pass(F:SymanticsL) = struct
  module X0 = struct
    type 'a from = 'a F.repr
    type 'a term =
      | Unknown  : 'a from -> 'a term
      | Where    : bool term * (unit -> 'a list term) -> 'a list term
    let fwd x = Unknown x
    let rec bwd : type a. a term -> a from = function
      | Unknown e   -> e
      | Where (t,b) -> F.where (bwd t) (fun () -> bwd (b ()))
  end
  open X0
  module X = Trans_def(X0)
  open X
  module IDelta = struct
    let where test body = Where(test, body)
    let rec foreach src body =
      match src () with
      | Where(t, b) -> fwd @@ F.where (bwd t) (fun () ->
                              F.foreach (fun () -> bwd @@ b ()) (fun x ->
                              bwd @@body (fwd x)))
      | _           -> fwd @@ F.foreach (fun () ->
                              bwd @@ src ()) (fun x ->
                              bwd @@ body (fwd x))
   end
end

module ForWhere(F:SymanticsL) = struct
  module OptM  = ForWhere_pass(F)
  include OL(OptM.X)(F)
  include OptM.IDelta
end


(* [ForEmpty1]
   foreach (fun () -> nil ())
           (fun x -> N)
   ---> nil ()
*)
module ForEmpty1_pass(F:SymanticsL) = struct
  module X0 = struct
    type 'a from = 'a F.repr
    type 'a term =
      | Unknown : 'a from -> 'a term
      | Nil     : unit -> 'a list term
    let fwd e = Unknown e
    let rec bwd : type a. a term -> a from = function
      | Unknown e -> e
      | Nil ()    -> F.nil ()
  end
  open X0
  module X = Trans_def(X0)
  open X
  module IDelta = struct
    let nil () = Nil ()
    let foreach src body =
      match src () with
      | Nil ()    -> fwd @@ F.nil ()
      | Unknown e -> fwd @@ F.foreach (fun () -> bwd @@ src ()) (fun x ->
                              bwd @@ body (fwd x))
  end
end

module ForEmpty1(F:SymanticsL) = struct
  module OptM  = ForEmpty1_pass(F)
  include OL(OptM.X)(F)
  include OptM.IDelta
end


(* [ForUnionAll1]
   foreach (fun () -> L @% M) (fun x () -> N)
   ---> foreach (fun () -> L)
                (fun x -> M)
        @%
        foreach (fun () -> L)
                (fun x -> N)
*)
module ForUnionAll1_pass(F:SymanticsL) = struct
  module X0 = struct
    type 'a from = 'a F.repr
    type 'a term =
      | Unknown  : 'a from -> 'a term
      | UnionAll : ('a list term * 'a list term) -> 'a list term
    let fwd x = Unknown x
    let rec bwd : type a. a term -> a from = function
      | Unknown x     -> x
      | UnionAll(x,y) -> F.(@%) (bwd x) (bwd y)
  end
  open X0
  module X = Trans_def(X0)
  open X
  module IDelta = struct
    let (@%) e1 e2 = UnionAll(e1, e2)
    let foreach src body =
      match src () with
      | Unknown x     -> fwd @@ F.foreach (fun () -> bwd @@ src ()) (fun x ->
                                 bwd @@ body (fwd x))
      | UnionAll(x,y) -> fwd @@ F.(@%) (F.foreach (fun () -> bwd x) (fun x' ->
                                          bwd @@ body (fwd x')))
                                       (F.foreach (fun () -> bwd y) (fun y' ->
                                          bwd @@ body (fwd y')))
  end
end

module ForUnionAll1(F:SymanticsL) = struct
  module OptM  = ForUnionAll1_pass(F)
  include OL(OptM.X)(F)
  include OptM.IDelta
end


(* [WhereTrue]
   where true (fun () -> L)
   ---> L
*)
module WhereTrue_pass(F:SymanticsL) = struct
  module X0 = struct
    type 'a from = 'a F.repr
    type 'a term =
      | Bool : bool -> bool term
      | Unknown : 'a from -> 'a term
    let fwd x = Unknown x
    let rec bwd : type a. a term -> a from = function
      | Unknown x -> x
      | Bool b -> F.bool b
  end
  open X0
  module X = Trans_def(X0)
  open X
  module IDelta = struct
    let bool b = Bool b
    let where test body =
      if test = (Bool true) then body ()
      else fwd @@ F.where (bwd test) (fun () ->
                    bwd @@ body ())
  end
end

module WhereTrue(F:SymanticsL) = struct
  module OptM  = WhereTrue_pass(F)
  include OL(OptM.X)(F)
  include OptM.IDelta
end

(* [WhereFalse]
   where false (fun () -> L)
   ---> nil ()
*)
module WhereFalse_pass(F:SymanticsL) = struct
  module M = WhereTrue_pass(F)
  module X0 = M.X0
  open X0
  module X = M.X
  open X
  module IDelta = struct
    let bool b = Bool b
    let where test body =
      if test = (Bool false) then fwd @@ F.nil ()
      else fwd @@ F.where (bwd test) (fun () ->
                    bwd @@ body ())
  end
end

module WhereFalse(F:SymanticsL) = struct
  module OptM  = WhereFalse_pass(F)
  include OL(OptM.X)(F)
  include OptM.IDelta
end


(*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  Stage 2
  \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
*)
(* [ForUnionAll2]
   foreach (fun () -> L) (fun x -> M @% N)
   ===> foreach (fun () -> L)
                (fun x -> M)
        @%
        foreach (fun () -> L)
                (fun x -> N)

We need to analyze the body of a function in this rule.
*)

(* This implementation uses no staging or delimited control.
   It is quite inefficient, but would suffice for now.
*)
module type Trans_dyn = sig
  include Trans
  val dyn : 'a term -> (unit -> 'a from)
  val fmap3 : ('a from -> 'b from -> 'c from -> 'd from) ->
              ('a term -> 'b term -> 'c term -> 'd term)
end

module ForUnionAll2_pass(F:SymanticsL) = struct
  module X = struct
    type 'a from = 'a F.repr
    type 'a term =
      | Unknown  : (unit -> 'a from) -> 'a term
      | UnionAll : 'a list term * 'a list term -> 'a list term
      (* One should use fmap and fmap2, etc.
         When one use fwd, its argument that has a dummy value might be evaluated. *)
    let fwd x = Unknown (fun () -> x)
    let bwd x = failwith "should not use" (* Runcode.run x *)
    let rec dyn : type a. a term -> (unit -> a from) = function
      | Unknown x      -> x
      | UnionAll (x,y) -> fun () -> F.(@%) (dyn x ()) (dyn y ())
    let fmap  f termx       = Unknown (fun () -> f (dyn termx ()))
    let fmap2 f termx termy = Unknown (fun () -> f (dyn termx ()) (dyn termy ()))
    let fmap3 f t1 t2 t3    = Unknown (fun () -> f (dyn t1 ()) (dyn t2 ()) (dyn t3 ()))
    let fmap4 f t1 t2 t3 t4 = Unknown (fun () -> f (dyn t1 ()) (dyn t2 ()) (dyn t3 ()) (dyn t4 ()))
  end
  open X
  module IDelta = struct
    type side = Left | Right

    let (@%) x y = UnionAll(x,y)

    let foreach src body =
      let srcc = dyn (src ()) in
      let tryloop n = fun () ->
        F.foreach (fun () -> srcc ())
          (fun x ->
            match body (Unknown (fun () -> x)) with
            | Unknown x -> x ()
            | UnionAll(x,y) ->
                if n=Left then dyn x () else dyn y ())
          (* check what kind of for loop body it is,
             using a dummy variable.
             Informally, we check what sort of code it may generate *)
      in match body (Unknown (fun () -> failwith "dummy var in ForUnionAll2")) with
         | Unknown _ ->
             Unknown (tryloop Left)            (* Now generate for real *)
         | UnionAll (_,_) ->
             Unknown (tryloop Left) @% Unknown (tryloop Right)

    (* replace some function that call bwd *)
    let if_ test x y = Unknown (fun () ->
        F.if_ (dyn test ()) (fun () -> dyn (x ()) ()) (fun () -> dyn (y ()) ()))

    let lam f = Unknown (fun () ->
      F.lam (fun x -> dyn (f (fwd x)) ()))

    let where test body = Unknown (fun () ->
        F.where (dyn test ()) (fun () -> (dyn (body ()) ())))

    let observe x = F.observe @@ dyn (x ())
   end
end


module ForUnionAll2(F:SymanticsL) = struct
  module OptM  = ForUnionAll2_pass(F)
  include OL(OptM.X)(F)
  include OptM.IDelta
end


(* --------------------------------------
   [ForEmpty2]
   foreach (fun () -> L) (fun x -> nil ())
   ===> nil ()
   ------------------------------------*)
module ForEmpty2_pass(F:SymanticsL) = struct
  module X = struct
    type 'a from = 'a F.repr
    type 'a term = Unknown : (unit -> 'a from) -> 'a term
                 | Nil     : unit -> 'a list term
    let fwd x = Unknown (fun () -> x)
    let bwd x = failwith "should not use (ForEmpty2)"
    let rec dyn : type a. a term -> (unit -> a from) = function
      | Unknown x -> x
      | Nil ()    -> fun () -> F.nil ()
    let fmap  f termx       = Unknown (fun () -> f (dyn termx ()))
    let fmap2 f termx termy = Unknown (fun () -> f (dyn termx ()) (dyn termy ()))
    let fmap3 f t1 t2 t3    = Unknown (fun () -> f (dyn t1 ()) (dyn t2 ()) (dyn t3 ()))
    let fmap4 f t1 t2 t3 t4 = Unknown (fun () -> f (dyn t1 ()) (dyn t2 ()) (dyn t3 ()) (dyn t4 ()))
  end
  open X
  module IDelta = struct
    let nil () = Nil ()
    let foreach src body =
      match body (Unknown (fun () -> failwith "dummy var in ForEmpty2"))with
      | Nil () -> fwd (F.nil ())
      | _      -> fwd @@ (F.foreach (fun () ->
                          dyn (src ()) ()) (fun x ->
                          dyn (body (fwd x)) ()))

    let if_ test x y = Unknown (fun () ->
        F.if_ (dyn test ()) (fun () -> dyn (x ()) ()) (fun () -> dyn (y ()) ()))

    let lam f = Unknown (fun () ->
      F.lam (fun x -> dyn (f (fwd x)) ()))

    let where test body = Unknown (fun () ->
        F.where (dyn test ()) (fun () -> (dyn (body ()) ())))
    let observe x = F.observe @@ dyn (x ())
  end
end

module ForEmpty2(F:SymanticsL) = struct
  module M = ForEmpty2_pass(F)
  include OL(M.X)(F)
  include M.IDelta
end

(* --------------------------------------
   [WhereEmpty]
   where L (fun () -> nil ())
   ===> nil ()
   ------------------------------------*)
module WhereEmpty_pass(F:SymanticsL) = struct
  module X0 = struct
    type 'a from = 'a F.repr
    type 'a term = Unknown : 'a from -> 'a term
                 | Nil     : unit -> 'a list term
    let fwd x = Unknown x
    let rec bwd : type a. a term -> a from = function
      | Unknown e -> e
      | Nil ()    -> F.nil ()
  end
  open X0
  module X = Trans_def(X0)
  open X
  module IDelta = struct
    let nil () = Nil ()
    let where test body =
      match body () with
      | Nil ()    -> fwd (F.nil ())
      | Unknown x -> fwd @@ F.where (bwd test) (fun () ->
                            bwd @@ body ())
  end
end

module WhereEmpty(F:SymanticsL) = struct
  module M = WhereEmpty_pass(F)
  include OL(M.X)(F)
  include M.IDelta
end

(* --------------------------------------
   [WhereWhere]
   where L (fun () -> where M (fun () -> N))
   ===> where (L && M) (fun () -> N)
   ------------------------------------*)
module WhereWhere_pass(F:SymanticsL) = struct
  module X0 = struct
    type 'a from = 'a F.repr
    type 'a term =
      | Unknown  : 'a from -> 'a term
      | Where    : bool term * (unit -> 'a list term) -> 'a list term
    let fwd x = Unknown x
    let rec bwd : type a. a term -> a from = function
      | Unknown e   -> e
      | Where (t,b) -> F.where (bwd t) (fun () -> bwd (b ()))
  end
  open X0
  module X = Trans_def(X0)
  open X
  module IDelta = struct
    let where test body =
      match body () with
      | Where(t,b) -> fwd @@ F.where (F.(&%) (bwd test) (bwd t)) (fun () -> bwd @@ b ())
      | Unknown x -> Where(test,body)
  end
end

module WhereWhere(F:SymanticsL) = struct
  module M = WhereWhere_pass(F)
  include OL(M.X)(F)
  include M.IDelta
end



(* --------------------------------------
   [WhereFor]
   where L (fun () ->
   foreach (fun () -> M) (fun x -> N))
   ===> foreach (fun () -> M) (fun x ->
        where L (fun () -> N))
   ------------------------------------*)
module WhereFor_pass(F:SymanticsL) = struct
  module X0 = struct
    type 'a from = 'a F.repr
    type 'a term = Unknown : 'a from -> 'a term
                 | For     : (unit -> 'a list term) * ('a term -> 'b list term) -> 'b list term
    let fwd x = Unknown x
    let rec bwd : type a. a term -> a from = function
      | Unknown e -> e
      | For (t,b) -> F.foreach (fun () -> bwd @@ t ()) (fun x -> bwd @@ b (fwd x))
  end
  open X0
  module X = Trans_def(X0)
  open X
  module IDelta = struct
    let foreach src body = For(src,body)

    let where test body =
      match body () with
      | For(t,b)  -> fwd @@ F.foreach (fun () -> bwd @@ t ()) (fun x ->
                            F.where (bwd test) (fun () -> bwd @@ b (fwd x)))
      | Unknown x -> fwd @@ F.where (bwd test) (fun () -> bwd @@ body ())
  end
end

module WhereFor(F:SymanticsL) = struct
  module M = WhereFor_pass(F)
  include OL(M.X)(F)
  include M.IDelta
end
