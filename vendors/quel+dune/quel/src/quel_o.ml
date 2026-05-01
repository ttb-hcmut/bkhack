open Quel_sym

(*
   Query optimization framework in tagless-final
   Basic infrastructure
 *)
module type Trans_base = sig
  type 'a from
  type 'a term
  val fwd : 'a from -> 'a term (* reflection *)
  val bwd : 'a term -> 'a from (* reification *)
end
(* In PPL 2015, fwd/bwd are called up/down *)

(* Adding mapping functions. Do we need famp3 etc? (NO)
      Can we do with less?
*)
module type Trans = sig
  include Trans_base
  val fmap  : ('a from -> 'b from) -> ('a term -> 'b term)
  val fmap2 : ('a from -> 'b from -> 'c from) ->
              ('a term -> 'b term -> 'c term)
end

(* Add the default implementations of the mapping functions *)
module Trans_def(X:Trans_base) = struct
  include X
  let fmap  f term        = fwd (f (bwd term))
  let fmap2 f term1 term2 = fwd (f (bwd term1) (bwd term2))
end


(* The default, generic optimizer
   Concrete optimizers are built by overriding the interpretations
   of some DSL forms.
*)
module O(X:Trans)
        (F:Symantics with type 'a repr = 'a X.from) = struct
  open X

  type 'a repr = 'a term
  type 'a obs  = 'a F.obs

  let int (n:int)       = fwd (F.int n)
  let float (f:float)   = fwd (F.float f)
  let bool (b:bool)     = fwd (F.bool b)
  let string (s:string) = fwd (F.string s)

  let (+%)     = fmap2 (F.(+%))
  let (-%)     = fmap2 (F.(-%))
  let ( *%)    = fmap2 (F.( *%))
  let (/%)     = fmap2 (F.(/%))

  let (+%.)    = fmap2 (F.(+%.))
  let (-%.)    = fmap2 (F.(-%.))
  let ( *%.)   = fmap2 (F.( *%.))
  let (/%.)    = fmap2 (F.(/%.))

  let (>%) e1 e2 = fmap2 F.(>%) e1 e2
  let (<%) e1 e2 = fmap2 F.(<%) e1 e2
  let (=%) e1 e2 = fmap2 F.(=%) e1 e2

  let (>%.) e1 e2 = fmap2 F.(>%.) e1 e2
  let (<%.) e1 e2 = fmap2 F.(<%.) e1 e2
  let (=%.) e1 e2 = fmap2 F.(=%.) e1 e2

  let (>&) e1 e2 = fmap2 F.(>&) e1 e2
  let (<&) e1 e2 = fmap2 F.(<&) e1 e2
  let (=&) e1 e2 = fmap2 F.(=&) e1 e2

  let (>@) e1 e2 = fmap2 F.(>@) e1 e2
  let (<@) e1 e2 = fmap2 F.(<@) e1 e2
  let (=@) e1 e2 = fmap2 F.(=@) e1 e2

  let (!%)     = fmap  (F.(!%))
  let (&%)     = fmap2 (F.(&%))
  let (|%)     = fmap2 (F.(|%))

  let if_ e e1 e2 = fwd @@ F.if_ (bwd e) (fun () -> bwd @@ e1 ()) (fun () -> bwd @@ e2 ())

  let lam f     = fwd (F.lam (fun x -> bwd (f (fwd x))))
  let app e1 e2 = fmap2 F.app e1 e2

  let observe x = F.observe (fun () -> bwd (x ()))
end

module OL(X:Trans)
         (F:SymanticsL with type 'a repr = 'a X.from)  = struct
  include O(X)(F)
  open X

  let foreach src body =
    fwd (F.foreach (fun () -> bwd (src ())) (fun x -> bwd (body (fwd x))))
  let where test body  =
    fwd (F.where (bwd test) (fun () -> bwd (body ())))
  let yield e    = fmap F.yield e
  let nil ()     = fwd (F.nil ())
  let exists e   = fmap F.exists e
  let (@%) e1 e2 = fmap2 F.(@%) e1 e2

  let table (name,data) =
    fwd @@ F.table (name, data)
end
