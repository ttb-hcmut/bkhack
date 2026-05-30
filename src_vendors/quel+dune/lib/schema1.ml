(*
#load "quel.cma";;
*)

open Quel_sym
open Quel_r
open Quel_p
open Quel_sql
open Quel_o
open Quel_norm
open Format

(*--------------------------------------------------------------------*)
(*
 * An example schema definition as a symantics interface
 *)
module type SCHEMA = sig
  type 'a repr

  (* input / output records *)
  val product : int repr -> string repr -> int repr ->
                <pid:int; name:string; price:int> repr

  val order   : int repr -> int repr -> int repr ->
                <oid:int; pid:int; qty:int> repr

  val sales   : int repr -> string repr -> int repr ->
                <pid:int; name:string; sale:int> repr

  (* projection *)
  val pid      : <pid:int; name:string; price:int> repr -> int repr
  val name     : <pid:int; name:string; price:int> repr -> string repr
  val price    : <pid:int; name:string; price:int> repr -> int repr

  val oid      : <oid:int; pid:int; qty:int> repr -> int repr
  val opid     : <oid:int; pid:int; qty:int> repr -> int repr
  val qty      : <oid:int; pid:int; qty:int> repr -> int repr

  val spid     : <pid:int; name:string; sale:int> repr -> int repr
  val sname    : <pid:int; name:string; sale:int> repr -> string repr
  val sale     : <pid:int; name:string; sale:int> repr -> int repr

  (* data sources *)
  val products : unit -> <pid:int; name:string; price:int> list
  val orders   : unit -> <oid:int; pid:int; qty:int> list
end

(* composition of Symantics and SCHEMA *)
module type SYM_SCHEMA = sig
  include SymanticsL
  include SCHEMA  with type 'a repr := 'a repr
end

(*--------------------------------------------------------------------*)
(*
 * Interpreters for the schema
 *)

(*------------------------------------*)
(* the R interpreter with the schema *)
module R_schema = struct
  type 'a repr = 'a

  let product pid name price =
    object
      method pid  = pid
      method name = name
      method price = price
    end

  let order oid pid qty =
    object
      method oid = oid
      method pid = pid
      method qty = qty
    end

  let sales pid name sale =
    object
      method pid  = pid
      method name = name
      method sale = sale
    end

  (* projection *)
  let pid  o     = o#pid
  let name o     = o#name
  let price o    = o#price

  let oid o      = o#oid
  let opid o     = o#pid
  let qty o      = o#qty

  let spid o     = o#pid
  let sname o    = o#name
  let sale o     = o#sale

  (* data sources *)
  let products () =
    [ product 1 "Tablet"  500;
      product 2 "Laptop"  1000;
      product 3 "Desktop" 1000;
      product 4 "Router"  150;
      product 5 "HDD"     100;
      product 6 "SDD"     500;
    ]

  let orders () =
    [ order 1 1 5;
      order 1 2 5;
      order 1 4 2;
      order 2 5 10;
      order 2 6 20;
      order 3 2 50;
    ]
end

(* Compose the RL interpreter and the schema
   For simplicity, we redefine the name of `R'
*)
module R = struct
  include RL
  include (R_schema : SCHEMA
           with type 'a repr := 'a repr)
end


(*------------------------------------*)
(* the P interpreter with the schema *)
module P = struct
  include PL

  (* records *)
  let product pid name price = fun p v ppf ->
    fprintf ppf "@[<2><pid=%t;name=%t;price=%t>@]"
      (pid p v) (name p v) (price p v)

  let order oid pid qty = fun p v ppf ->
    fprintf ppf "@[<2><oid=%t;pid=%t;qty=%t>@]"
      (oid p v) (pid p v) (qty p v)

  let sales pid name sale = fun p v ppf ->
    fprintf ppf "@[<2><pid=%t;name=%t;sale=%t>@]"
      (pid p v) (name p v) (sale p v)

  (* projection *)
  let print_projection r field_name = fun p v ppf ->
    paren ppf (p > 10) @@
    fun ppf -> fprintf ppf "@[<2>%t.%s@]" (r p v) field_name

  let pid r      = print_projection r "pid"
  let name r     = print_projection r "name"
  let price r    = print_projection r "price"

  let oid r   = print_projection r "oid"
  let opid r  = print_projection r "pid"
  let qty r   = print_projection r "qty"

  let spid r  = print_projection r "pid"
  let sname r = print_projection r "name"
  let sale r  = print_projection r "sale"

  (* data sources, it not use in printing *)
  let products = fun () -> []
  let orders   = fun () -> []
end


(*------------------------------------*)
(* the SQL translator with the schema *)
module GenSQL = struct
  include GenSQL

  (* records *)
  let product pid name price =
    record @@ ("pid" %: pid) %* (row1 ("name" %: name))
  let order oid pid qty =
    record @@ ("oid" %: oid) %* ("pid" %: pid) %* (row1 ("qty" %: qty))
  let sales pid name sale =
    record @@ ("pid" %: pid) %* ("name" %: name) %* (row1 ("sale" %: sale))

  (* projection *)
  let pid r      = r %. "pid"
  let name r     = r %. "name"
  let price r    = r %. "price"

  let oid r   = r %. "oid"
  let opid r  = r %. "pid"
  let qty r   = r %. "qty"

  let spid r  = r %. "pid"
  let sname r = r %. "name"
  let sale r  = r %. "sale"

  (* data sources, it not use in the SQL translation *)
  let products = fun () -> []
  let orders   = fun () -> []
end

(*------------------------------------*)
(* the optimizer with the schema *)

(* The default optimizer for the schema *)
module O_schema(X:Trans)(S:SYM_SCHEMA with type 'a repr = 'a X.from) = struct
  open X
  open S

    (* records *)
  let product pid name price =
    fwd @@ S.product (bwd pid) (bwd name) (bwd price)

  let order oid pid qty =
    fwd @@ S.order (bwd oid) (bwd pid) (bwd qty)

  let sales pid name sale =
    fwd @@ S.sales (bwd pid) (bwd name) (bwd sale)

  (* projection *)
  let pid      = fun o -> fwd @@ S.pid (bwd o)
  let name     = fun o -> fwd @@ S.name (bwd o)
  let price    = fun o -> fwd @@ S.price (bwd o)

  let oid o    = fmap S.oid o
  let opid o   = fmap S.opid o
  let qty o    = fmap S.qty o

  let spid     = fun o -> fwd @@ S.spid (bwd o)
  let sname    = fun o -> fwd @@ S.sname (bwd o)
  let sale     = fun o -> fwd @@ S.sale (bwd o)

  (* data sources; these are not used in optimizations *)
  let products = S.products
  let orders   = S.orders
end

module O
    (X:Trans)
    (S:SYM_SCHEMA with type 'a repr = 'a X.from) = struct
  include OL(X)(S)
  include (O_schema(X)(S): SCHEMA
           with type 'a repr := 'a repr)

end


(* Optimization rules with the schema *)

(* Compose normalizations and the schema *)
module AbsBeta(F:SYM_SCHEMA) = struct
  module M = AbsBeta_pass(F)
  include O(M.X)(F)
  include M.IDelta
end


(* beta-reduction for record *)
module RecordBeta_pass(F:SYM_SCHEMA) = struct
  module X0 = struct
    type 'a from = 'a F.repr
    type 'a term =
      | Unknown : 'a from -> 'a term
      | Product : (int term * string term * int term) ->
        <pid:int;name:string;price:int> term
      | Order   : (int term * int term * int term) ->
        <oid:int;pid:int;qty:int> term
      | Sales   : (int term * string term * int term) ->
        <pid:int; name:string; sale:int> term
    let fwd x = Unknown x
    let rec bwd : type a. a term -> a from = function
      | Unknown x  -> x
      | Product(pid,name,price) ->
        F.product (bwd pid) (bwd name) (bwd price)
      | Order(oid,pid,qty) ->
        F.order (bwd oid) (bwd pid) (bwd qty)
      | Sales(pid,name,sale) ->
        F.sales (bwd pid) (bwd name) (bwd sale)
  end
  open X0
  module X = Trans_def(X0)
  open X
  module IDelta = struct
    (* records *)
    let product pid name price =
      Product(pid,name,price)
    let order oid pid qty =
      Order(oid,pid,qty)
    let sales pid name sale =
      Sales(pid,name,sale)

    (* projection *)
    (* We don't use row polymorphism to encode record projection (such as `pid`)
       because locally abstract type a is not compatible with type 'a.contents
       When `pid` corresponds to `product` and `order`, the following error occurs.

      let pid : type a. a term -> int term = function
      | Product(pid,_,_,_) -> pid
      | Order(_,pid,_) -> pid
      | x -> fwd @@ F.pid (bwd x)

      Error: This expression has type a X.from = a F.repr
       but an expression was expected of type
         (< pid : int; .. > as 'a) F.repr
       Type a is not compatible with type 'a *)
    let pid = function
      | Product(pid,_,_) -> pid
      | x -> fwd @@ F.pid (bwd x)
    let name = function
      | Product(_,name,_) -> name
      | x -> fwd @@ F.name (bwd x)
    let price = function
      | Product(_,_,price) -> price
      | x -> fwd @@ F.price (bwd x)

    let oid = function
      | Order(oid,_,_) -> oid
      | x -> fwd @@ F.oid (bwd x)
    let opid = function
      | Order(_,pid,_) -> pid
      | x -> fwd @@ F.opid (bwd x)
    let qty = function
      | Order(_,_,qty) -> qty
      | x -> fwd @@ F.qty (bwd x)

    let spid = function
      | Sales(pid,_,_) -> pid
      | x -> fwd @@ F.spid (bwd x)
    let sname = function
      | Sales(_,name,_) -> name
      | x -> fwd @@ F.sname (bwd x)
    let sale = function
      | Sales(_,_,sale) -> sale
      | x -> fwd @@ F.sale (bwd x)
  end
end



module RecordBeta(F:SYM_SCHEMA) = struct
  module M = RecordBeta_pass(F)
  include O(M.X)(F)
  include M.IDelta
end

module ForYield(F:SYM_SCHEMA) = struct
  module M = Quel_norm.ForYield_pass(F)
  include O(M.X)(F)
  include M.IDelta
end

module ForFor(F:SYM_SCHEMA) = struct
  module M = Quel_norm.ForFor_pass(F)
  include O(M.X)(F)
  include M.IDelta
end

module ForWhere(F:SYM_SCHEMA) = struct
  module M = Quel_norm.ForWhere_pass(F)
  include O(M.X)(F)
  include M.IDelta
end

module ForEmpty1(F:SYM_SCHEMA) = struct
  module M = Quel_norm.ForEmpty1_pass(F)
  include O(M.X)(F)
  include M.IDelta
end

module ForUnionAll1(F:SYM_SCHEMA) = struct
  module M = Quel_norm.ForUnionAll1_pass(F)
  include O(M.X)(F)
  include M.IDelta
end

module WhereTrue(F:SYM_SCHEMA) = struct
  module M = Quel_norm.WhereTrue_pass(F)
  include O(M.X)(F)
  include M.IDelta
end

module WhereFalse(F:SYM_SCHEMA) = struct
  module M = Quel_norm.WhereFalse_pass(F)
  include O(M.X)(F)
  include M.IDelta
end

(* the default optimizer of the schema that use dyn instead bwd.
   This is used in the normalization that analyze the body of lambda-abstraction. *)
module Dyn_schema(X:Trans_dyn)(F:SYM_SCHEMA with type 'a repr = 'a X.from) = struct
  open X
  open F

  (* records *)
  let product pid name price =
    fmap3 F.product pid name price
  let order oid pid qty =
    fmap3 F.order oid pid qty
  let sales pid name sale =
    fmap3 F.sales pid name sale

  (* projection *)
  let pid o      = fmap F.pid o
  let name o     = fmap F.name o
  let price o    = fmap F.price o

  let oid o   = fmap F.oid o
  let opid o  = fmap F.opid o
  let qty o   = fmap F.qty o

  let spid o  = fmap F.spid o
  let sname o = fmap F.sname o
  let sale o  = fmap F.sale o

  let products = F.products
  let orders   = F.orders
end

module ForUnionAll2(F:SYM_SCHEMA) = struct
  module M = Quel_norm.ForUnionAll2_pass(F)
  include OL(M.X)(F)
  include Dyn_schema(M.X)(F)
  include M.IDelta
end

module ForEmpty2(F:SYM_SCHEMA) = struct
  module M = Quel_norm.ForEmpty2_pass(F)
  include OL(M.X)(F)
  include M.IDelta
  include Dyn_schema(M.X)(F)
end

module WhereEmpty(F:SYM_SCHEMA) = struct
  module M = Quel_norm.WhereEmpty_pass(F)
  include O(M.X)(F)
  include M.IDelta
end

module WhereWhere(F:SYM_SCHEMA) = struct
  module M = Quel_norm.WhereWhere_pass(F)
  include O(M.X)(F)
  include M.IDelta
end

module WhereFor(F:SYM_SCHEMA) = struct
  module M = Quel_norm.WhereFor_pass(F)
  include O(M.X)(F)
  include M.IDelta
end

(* Composing transformations *)
module Norm(F:SYM_SCHEMA) = struct
  (* All normalization rules *)
  module AllPasses = AbsBeta(RecordBeta(ForYield(ForFor(ForWhere(ForEmpty1(ForUnionAll1(WhereTrue(WhereFalse(ForUnionAll2(ForEmpty2(WhereEmpty(WhereWhere(WhereFor(F))))))))))))))

  (* Mainly rules *)
  module MainPasses = AbsBeta(RecordBeta(ForFor(ForWhere(ForYield(WhereFor(WhereWhere(F)))))))
end

(* Repeating for the normalization *)
module rec FixP : (SYM_SCHEMA with type 'a obs = 'a P.obs) = struct
  module T = Norm(FixP)
  module TFix = T.AllPasses  (* T.MainPasses *)
  module S = P

  type 'a repr =
    {again: unit -> 'a TFix.repr;
     last:  unit -> 'a S.repr}
  type 'a obs  = 'a S.obs

  (* record *)
  let product pid name price =
    {again = (fun () -> TFix.product (pid.again ()) (name.again ()) (price.again ()));
     last  = (fun () -> S.product (pid.last ()) (name.last ()) (price.last ())); }

  let order oid pid qty =
    {again = (fun () -> TFix.order (oid.again ()) (pid.again ()) (qty.again ()));
     last  = (fun () -> S.order (oid.last ()) (pid.last ()) (qty.last ())); }

  let sales pid name sale =
    {again = (fun () -> TFix.sales (pid.again ()) (name.again ()) (sale.again ()));
     last  = (fun () -> S.sales (pid.last ()) (name.last ()) (sale.last ())); }


  let pid r =
    {again = (fun () -> TFix.pid (r.again ()));
     last  = (fun () -> S.pid (r.last ())); }
  let name r =
    {again = (fun () -> TFix.name (r.again ()));
     last  = (fun () -> S.name (r.last ())); }
  let price r =
    {again = (fun () -> TFix.price (r.again ()));
     last  = (fun () -> S.price (r.last ())); }

  let oid r =
    {again = (fun () -> TFix.oid (r.again ()));
     last  = (fun () -> S.oid (r.last ())); }
  let opid r =
    {again = (fun () -> TFix.opid (r.again ()));
     last  = (fun () -> S.opid (r.last ())); }
  let qty r =
    {again = (fun () -> TFix.qty (r.again ()));
     last  = (fun () -> S.qty (r.last ())); }

  let spid r =
    {again = (fun () -> TFix.spid (r.again ()));
     last  = (fun () -> S.spid (r.last ())); }
  let sname r =
    {again = (fun () -> TFix.sname (r.again ()));
     last  = (fun () -> S.sname (r.last ())); }
  let sale r =
    {again = (fun () -> TFix.sale (r.again ()));
     last  = (fun () -> S.sale (r.last ())); }



  let products () = S.products ()
  let orders () = S.orders ()

  let binop op1 op2 x y = {again = (fun () -> op1 (x.again ()) (y.again ()));
                           last  = (fun () -> op2 (x.last ()) (y.last ()));}

  let int    n = {again = (fun () -> TFix.int n);
                  last  = (fun () -> S.int n)}
  let float  f = {again = (fun () -> TFix.float f);
                  last  = (fun () -> S.float f)}
  let bool   b = {again = (fun () -> TFix.bool b);
                  last  = (fun () -> S.bool b)}
  let string s = {again = (fun () -> TFix.string s);
                  last  = (fun () -> S.string s)}

  let (+%)  x y  = binop (TFix.(+%)) (S.(+%)) x y
  let (-%)  x y  = binop (TFix.(-%)) (S.(-%)) x y
  let ( *%) x y  = binop (TFix.( *%)) (S.( *%)) x y
  let (/%)  x y  = binop (TFix.(/%)) (S.(/%)) x y

  let (+%.)  x y = binop (TFix.(+%.)) (S.(+%.)) x y
  let (-%.)  x y = binop (TFix.(-%.)) (S.(-%.)) x y
  let ( *%.) x y = binop (TFix.( *%.)) (S.( *%.)) x y
  let (/%.)  x y = binop (TFix.(/%.)) (S.(/%.)) x y

  let (>%)  x y  = binop (TFix.(>%)) (S.(>%)) x y
  let (<%)  x y  = binop (TFix.(<%)) (S.(<%)) x y
  let (=%)  x y  = binop (TFix.(=%)) (S.(=%)) x y

  let (>%.) x y  = binop (TFix.(>%.)) (S.(>%.)) x y
  let (<%.) x y  = binop (TFix.(<%.)) (S.(<%.)) x y
  let (=%.) x y  = binop (TFix.(=%.)) (S.(=%.)) x y

  let (>&)  x y  = binop (TFix.(>&)) (S.(>&)) x y
  let (<&)  x y  = binop (TFix.(<&)) (S.(<&)) x y
  let (=&)  x y  = binop (TFix.(=&)) (S.(=&)) x y

  let (>@)  x y  = binop (TFix.(>@)) (S.(>@)) x y
  let (<@)  x y  = binop (TFix.(<@)) (S.(<@)) x y
  let (=@)  x y  = binop (TFix.(=@)) (S.(=@)) x y

  let (!%)  x    = {
    again = (fun () -> TFix.(!%) (x.again ()));
    last  = (fun () -> S.(!%) (x.last ()))}

  let (&%)  x y  = binop (TFix.(&%)) (S.(&%)) x y
  let (|%)  x y  = binop (TFix.(|%)) (S.(|%)) x y

  let if_ b x y = {again = (fun () -> TFix.(if_) (b.again ())
                               (fun () -> (x ()).again ())
                               (fun () -> (y ()).again ()));
                   last  = (fun () -> S.(if_) (b.last ())
                               (fun () -> (x ()).last ())
                               (fun () -> (y ()).last ()))}

  let lam f = {
    again = (fun () ->
        TFix.lam (fun x ->
            let r = f {again = (fun () -> x);
                       last  = (fun () -> failwith "illegal call: lam 1")}
            in r.again ()));
    last  = (fun () ->
        S.lam (fun x ->
            let r = f {again = (fun () -> failwith "illegal call: lam 2");
                       last  = (fun () -> x)}
            in r.last ()));
  }

  let app x y = {
    again = (fun () -> TFix.app (x.again ()) (y.again ()));
    last  = (fun () -> S.app (x.last ()) (y.last ())) }


  let foreach src body = {
    again = (fun () -> TFix.foreach (fun () -> (src ()).again ()) (fun x ->
        let r = body {again = (fun () -> x);
                      last  = (fun () -> failwith "illegal call: foreach 1");}
            in r.again ()));
    last  = (fun () -> S.foreach (fun () -> (src ()).last ()) (fun x ->
        let r = body {again = (fun () -> failwith "illegal call: foreach 2");
                      last  = (fun () -> x);}
        in r.last ()));
  }

  let where test body = {
    again = (fun () -> TFix.where (test.again ()) (fun () ->
        let r = body ()
        in r.again ()));
    last  = (fun () -> S.where (test.last ()) (fun () ->
        let r = body ()
        in r.last ()))}

  let yield x = {
    again = (fun () -> TFix.yield (x.again ()));
    last  = (fun () -> S.yield (x.last ())); }

  let nil () = {
    again = (fun () -> TFix.nil ());
    last  = (fun () -> S.nil ()); }

  let exists x = {
    again = (fun () -> TFix.exists (x.again ()));
    last  = (fun () -> S.exists (x.last ())); }

  let (@%) x y = {
    again = (fun () -> TFix.(@%) (x.again ()) (y.again ()));
    last  = (fun () -> S.(@%) (x.last ()) (y.last ())); }

  let table (name,data) = {again = (fun () -> TFix.table (name,data));
                           last  = (fun () -> S.table (name,data))}

  let depth = ref 0
  let rec observe m =
    (* Printf.printf "[FixP] observe: depth %d\n" !depth; *)
    incr depth;
    let r = if !depth > 10
      then S.observe (fun () -> (m ()).last ())
      else TFix.observe (fun () -> (m ()).again ()) in
    decr depth;
    r

end


(* with normal-form checking *)
module rec FixGenSQL : (SYM_SCHEMA with type 'a obs = 'a GenSQL.obs) = struct
  module T = Norm(FixGenSQL)
  module TFix = T.MainPasses
  module S = GenSQL
  module NF = GenSQL (* checking normal form *)

  type 'a repr =
    {again: unit -> 'a TFix.repr;
     last:  unit -> 'a S.repr;
     form:  unit -> 'a NF.repr}
  type 'a obs  = 'a S.obs

  (* record *)
  let product pid name price =
    {again = (fun () -> TFix.product (pid.again ()) (name.again ()) (price.again ()));
     last  = (fun () -> S.product (pid.last ()) (name.last ()) (price.last ()));
     form  = (fun () -> NF.product (pid.form ()) (name.form ()) (price.form ())); }

  let order oid pid qty =
    {again = (fun () -> TFix.order (oid.again ()) (pid.again ()) (qty.again ()));
     last  = (fun () -> S.order (oid.last ()) (pid.last ()) (qty.last ()));
     form  = (fun () -> NF.order (oid.form ()) (pid.form ()) (qty.form ())); }

  let sales pid name sale =
    {again = (fun () -> TFix.sales (pid.again ()) (name.again ()) (sale.again ()));
     last  = (fun () -> S.sales (pid.last ()) (name.last ()) (sale.last ()));
     form  = (fun () -> NF.sales (pid.form ()) (name.form ()) (sale.form ())); }

  (* projection *)
  let pid r =
    {again = (fun () -> TFix.pid (r.again ()));
     last  = (fun () -> S.pid (r.last ()));
     form  = (fun () -> NF.pid (r.form ())); }
  let name r =
    {again = (fun () -> TFix.name (r.again ()));
     last  = (fun () -> S.name (r.last ()));
     form  = (fun () -> NF.name (r.form ())); }
  let price r =
    {again = (fun () -> TFix.price (r.again ()));
     last  = (fun () -> S.price (r.last ()));
     form  = (fun () -> NF.price (r.form ())); }

  let oid r =
    {again = (fun () -> TFix.oid (r.again ()));
     last  = (fun () -> S.oid (r.last ()));
     form  = (fun () -> NF.oid (r.form ())); }
  let opid r =
    {again = (fun () -> TFix.opid (r.again ()));
     last  = (fun () -> S.opid (r.last ()));
     form  = (fun () -> NF.opid (r.form ())); }
  let qty r =
    {again = (fun () -> TFix.qty (r.again ()));
     last  = (fun () -> S.qty (r.last ()));
     form  = (fun () -> NF.qty (r.form ())); }

  let spid r =
    {again = (fun () -> TFix.spid (r.again ()));
     last  = (fun () -> S.spid (r.last ()));
     form  = (fun () -> NF.spid (r.form ())); }
  let sname r =
    {again = (fun () -> TFix.sname (r.again ()));
     last  = (fun () -> S.sname (r.last ()));
     form  = (fun () -> NF.sname (r.form ())); }
  let sale r =
    {again = (fun () -> TFix.sale (r.again ()));
     last  = (fun () -> S.sale (r.last ()));
     form  = (fun () -> NF.sale (r.form ())); }

  (* data sources *)
  let products () = S.products ()
  let orders () = S.orders ()


  (* Symantics constructs *)
  let unop op1 op2 op3 x =
    {again = (fun () -> op1 (x.again ()));
     last  = (fun () -> op2 (x.last ()));
     form  = (fun () -> op3 (x.form ())); }

  let binop op1 op2 op3 x y =
    {again = (fun () -> op1 (x.again ()) (y.again ()));
     last  = (fun () -> op2 (x.last ()) (y.last ()));
     form  = (fun () -> op3 (x.form ()) (y.form ()));}

  let const op1 op2 op3 c =
    {again = (fun () -> op1 c);
     last  = (fun () -> op2 c);
     form  = (fun () -> op3 c); }

  let int    n = const TFix.int S.int NF.int n
  let float  f = const TFix.float S.float NF.float f
  let bool   b = const TFix.bool S.bool NF.bool b
  let string s = const TFix.string S.string NF.string s

  let (+%)  x y  = binop (TFix.(+%)) (S.(+%)) (NF.(+%)) x y
  let (-%)  x y  = binop (TFix.(-%)) (S.(-%)) (NF.(-%)) x y
  let ( *%) x y  = binop (TFix.( *%)) (S.( *%)) (NF.( *%)) x y
  let (/%)  x y  = binop (TFix.(/%)) (S.(/%)) (NF.(/%)) x y

  let (+%.)  x y = binop (TFix.(+%.)) (S.(+%.)) (NF.(+%.))  x y
  let (-%.)  x y = binop (TFix.(-%.)) (S.(-%.)) (NF.(-%.)) x y
  let ( *%.) x y = binop (TFix.( *%.)) (S.( *%.)) (NF.( *%.)) x y
  let (/%.)  x y = binop (TFix.(/%.)) (S.(/%.)) (NF.(/%.))x y

  let (>%)  x y  = binop (TFix.(>%)) (S.(>%)) (NF.(>%)) x y
  let (<%)  x y  = binop (TFix.(<%)) (S.(<%)) (NF.(<%)) x y
  let (=%)  x y  = binop (TFix.(=%)) (S.(=%)) (NF.(=%)) x y

  let (>%.) x y  = binop (TFix.(>%.)) (S.(>%.)) (NF.(>%.)) x y
  let (<%.) x y  = binop (TFix.(<%.)) (S.(<%.)) (NF.(<%.)) x y
  let (=%.) x y  = binop (TFix.(=%.)) (S.(=%.)) (NF.(=%.)) x y

  let (>&)  x y  = binop (TFix.(>&)) (S.(>&)) (NF.(>&)) x y
  let (<&)  x y  = binop (TFix.(<&)) (S.(<&)) (NF.(<&)) x y
  let (=&)  x y  = binop (TFix.(=&)) (S.(=&)) (NF.(=&)) x y

  let (>@)  x y  = binop (TFix.(>@)) (S.(>@)) (NF.(>@)) x y
  let (<@)  x y  = binop (TFix.(<@)) (S.(<@)) (NF.(<@)) x y
  let (=@)  x y  = binop (TFix.(=@)) (S.(=@)) (NF.(=@)) x y

  let (!%)  x    = unop (TFix.(!%)) (S.(!%)) (NF.(!%)) x

  let (&%)  x y  = binop (TFix.(&%)) (S.(&%)) (NF.(&%)) x y
  let (|%)  x y  = binop (TFix.(|%)) (S.(|%)) (NF.(|%)) x y

  let if_ b x y = {again = (fun () -> TFix.(if_) (b.again ())
                               (fun () -> (x ()).again ())
                               (fun () -> (y ()).again ()));
                   last  = (fun () -> S.(if_) (b.last ())
                               (fun () -> (x ()).last ())
                               (fun () -> (y ()).last ()));
                   form  = (fun () -> NF.(if_) (b.form ())
                               (fun () -> (x ()).form ())
                               (fun () -> (y ()).form ())); }

  let lam f = {
    again = (fun () ->
        TFix.lam (fun x ->
            let r = f {again = (fun () -> x);
                       last  = (fun () -> failwith "illegal call: lam 1");
                       form  = (fun () -> failwith "illegal call: lam 1"); }
            in r.again ()));
    last  = (fun () ->
        S.lam (fun x ->
            let r = f {again = (fun () -> failwith "illegal call: lam 2");
                       last  = (fun () -> x);
                       form  = (fun () -> failwith "illegal call: lam 2"); }
            in r.last ()));
    form  = (fun () ->
        NF.lam (fun x ->
            let r = f {again = (fun () -> failwith "illegal call: lam 3");
                       last  = (fun () -> failwith "illegal call: lam 3");
                       form  = (fun () -> x); }
            in r.form ()));
  }

  let app e1 e2 = binop TFix.app S.app NF.app e1 e2

  let foreach src body = {
    again = (fun () -> TFix.foreach (fun () -> (src ()).again ()) (fun x ->
        let r = body {again = (fun () -> x);
                      last  = (fun () -> failwith "illegal call: foreach 1");
                      form  = (fun () -> failwith "illegal call: foreach 1"); }
            in r.again ()));
    last  = (fun () -> S.foreach (fun () -> (src ()).last ()) (fun x ->
        let r = body {again = (fun () -> failwith "illegal call: foreach 2");
                      last  = (fun () -> x);
                      form  = (fun () -> failwith "illegal call: foreach 3"); }
        in r.last ()));
    form  = (fun () -> NF.foreach (fun () -> (src ()).form ()) (fun x ->
        let r = body {again = (fun () -> failwith "illegal call: foreach 3");
                      last  = (fun () -> failwith "illegal call: foreach 3");
                      form  = (fun () -> x); }
        in r.form ()));
  }

  let where test body = {
    again = (fun () -> TFix.where (test.again ()) (fun () ->
        let r = body ()
        in r.again ()));
    last  = (fun () -> S.where (test.last ()) (fun () ->
        let r = body ()
        in r.last ()));
    form  = (fun () -> NF.where (test.form ()) (fun () ->
        let r = body ()
        in r.form ())); }

  let yield x = unop TFix.yield S.yield NF.yield x

  let nil () = {
    again = (fun () -> TFix.nil ());
    last  = (fun () -> S.nil ());
    form  = (fun () -> NF.nil ()); }

  let exists x = unop TFix.exists S.exists NF.exists x

  let (@%) x y = binop TFix.(@%) S.(@%) NF.(@%) x y

  let table (name,data) = {again = (fun () -> TFix.table (name,data));
                           last  = (fun () -> S.table (name,data));
                           form  = (fun () -> NF.table (name,data)); }

  (*
  let depth = ref 0
  let rec observe m =
    (* Printf.printf "[FixGenSQL] observe: depth %d\n" !depth; *)
    incr depth;
    let r =
      if NF.check_NF (fun () -> (m ()).form ()) (* checking normal form *)
      then S.observe (fun () -> (m ()).last ())  (* generate an SQL query *)
      else if !depth > 100 then failwith "Normalization limit exceeded"
      else TFix.observe (fun () -> (m ()).again ()) (* normalize the term again *)
    in decr depth;
    r
    *)

  let depth = ref 0
  let rec observe m =
    (* Printf.printf "observe: depth %d\n" !depth; *)
    incr depth;
    let r = if !depth > 10
      then S.observe (fun () -> (m ()).last ())
      else TFix.observe (fun () -> (m ()).again ()) in
    decr depth;
    r

end
