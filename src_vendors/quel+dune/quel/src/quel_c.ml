(* Code generation *)

open Quel_sym

module C(S:Symantics) = struct
  type 'a repr = 'a S.repr code   (* wrap the abstract type *)

  (* constant constructors *)
  let int n    = .<S.int n>.
  let float f  = .<S.float f>.
  let bool b   = .<S.bool b>.
  let string s = .<S.string s>.

  let (+%)  e1 e2 = .<S.(+%) .~e1 .~e2>.
  let (-%)  e1 e2 = .<S.(-%) .~e1 .~e2>.
  let ( *%) e1 e2 = .<S.( *%) .~e1 .~e2>.
  let (/%)  e1 e2 = .<S.(/%) .~e1 .~e2>.

  let (+%.)  e1 e2 = .<S.(+%.) .~e1 .~e2>.
  let (-%.)  e1 e2 = .<S.(-%.) .~e1 .~e2>.
  let ( *%.) e1 e2 = .<S.( *%.) .~e1 .~e2>.
  let (/%.)  e1 e2 = .<S.(/%.) .~e1 .~e2>.

  let (>%)  e1 e2 = .<S.(>%) .~e1 .~e2>.
  let (<%)  e1 e2 = .<S.(<%) .~e1 .~e2>.
  let (=%)  e1 e2 = .<S.(=%) .~e1 .~e2>.

  let (>%.) e1 e2 = .<S.(>%.) .~e1 .~e2>.
  let (<%.) e1 e2 = .<S.(<%.) .~e1 .~e2>.
  let (=%.) e1 e2 = .<S.(=%.) .~e1 .~e2>.

  let (>&) e1 e2 = .<S.(>&) .~e1 .~e2>.
  let (<&) e1 e2 = .<S.(<&) .~e1 .~e2>.
  let (=&) e1 e2 = .<S.(=&) .~e1 .~e2>.

  let (>@) e1 e2 = .<S.(>@) .~e1 .~e2>.
  let (<@) e1 e2 = .<S.(<@) .~e1 .~e2>.
  let (=@) e1 e2 = .<S.(=@) .~e1 .~e2>.

  let (!%) e     = .<S.(!%) .~e >.
  let (&%) e1 e2 = .<S.(&%) .~e1 .~e2>.
  let (|%) e1 e2 = .<S.(|%) .~e2 .~e2>.

  let if_ e e1 e2 = .<S.if_ .~e (fun () -> .~(e1 ())) (fun () -> .~(e2 ()))>.

  let lam f     = .<S.lam (fun x -> .~(f .<x>.))>.
  let app e1 e2 = .<S.app .~e1 .~e2>.

  type 'a obs = 'a repr
  let observe x = x ()
end

module CL(S:SymanticsL) = struct
  include C(S)

  let foreach src body =
    .<S.foreach (fun () -> .~(src ())) (fun x -> .~(body .<x>.)) >.
  let where test body  =
    .<S.where .~test (fun () -> .~(body ()))>.
  let yield e    = .<S.yield .~e>.
  let nil ()     = .<S.nil ()>.
  let exists e   = .<S.exists .~e>.
  let (@%) e1 e2 = .<S.(@%) .~e1 .~e2>.

  let table (name, data) = .<S.table (name, data)>.
end
