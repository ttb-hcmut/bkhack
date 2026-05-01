(* Examples from Cheney et al.'s paper *)
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
 * The Shema definition as a symantics interface
 *)
module type SCHEMA = sig
  type 'a repr

  (* input / output records *)
  val people : string repr -> int repr ->
               <name:string;age:int> repr
  val names  : string repr -> <name:string> repr

  (* projection *)
  val name   : <name:string; age:int> repr -> string repr
  val age    : <name:string; age:int> repr -> int repr

  (* data sources *)
  val people_table : unit -> <name:string; age:int> list
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

  (* input / output record *)
  let people name age =
    object
      method name = name
      method age = age
    end

  let names name =
    object
      method name = name
    end

  (* projection *)
  let name o   = o#name
  let age o    = o#age

  (* data sources *)
  let people_table () =
    [ people "Alex" 60;
      people "Bert" 55;
      people "Cora" 33;
      people "Drew" 31;
      people "Edna" 21;
      people "Fred" 60;
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
  let people name age = fun p v ppf ->
    fprintf ppf "@[<2><name=%t;age=%t>@]" (name p v) (age p v)

  let names name = fun p v ppf ->
    fprintf ppf "@[<2><name=%t>@]" (name p v)

  (* projection *)
  let print_projection r field_name = fun p v ppf ->
    paren ppf (p > 10) @@
    fun ppf -> fprintf ppf "@[<2>%t.%s@]" (r p v) field_name

  let name r  = print_projection r "name"
  let age  r  = print_projection r "age"

  (* data sources, it not use in printing *)
  let people_table = fun () -> []
end


(*------------------------------------*)
(* the SQL translator with the schema *)
module GenSQL = struct
  include GenSQL

  (* records *)
  let people name age =
    record @@ ("name" %: name) %* (row1 ("age" %: age))
  let names name =
    record @@ row1 ("name" %: name)

  (* projection *)
  let name r  = r %. "name"
  let age r   = r %. "age"

  (* data sources, it not use in the SQL translation *)
  let people_table = fun () -> []
end

(*------------------------------------*)
(* the optimizer with the schema *)

(* The default optimizer for the schema *)
module O_schema(X:Trans)(S:SYM_SCHEMA with type 'a repr = 'a X.from) = struct
  open X
  open S

    (* records *)
  let people name age =
    fwd @@ S.people (bwd name) (bwd age)

  let names name =
    fwd @@ S.names (bwd name)

  (* projection *)
  let name   = fun o -> fwd @@ S.name (bwd o)
  let age    = fun o -> fwd @@ S.age (bwd o)

  (* data sources; these are not used in optimizations *)
  let people_table = S.people_table
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
      | People  : (string term * int term) -> <name:string; age:int> term
      | Names   : (string term)            -> <name:string> term
    let fwd x = Unknown x
    let rec bwd : type a. a term -> a from = function
      | Unknown x  -> x
      | People(name,age) -> F.people (bwd name) (bwd age)
      | Names(name) ->      F.names (bwd name)
  end
  open X0
  module X = Trans_def(X0)
  open X
  module IDelta = struct
    (* records *)
    let people name age = People(name,age)
    let names name = Names(name)

    (* projection *)
    let age = function
      | People(_,age) -> age
      | x -> fwd @@ F.age (bwd x)
    let name = function
      | People(name,_) -> name
      | x -> fwd @@ F.name (bwd x)
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
  let people name age = fmap2 F.people name age
  let names name = fmap F.names name

  (* projection *)
  let name o  = fmap F.name o
  let age o   = fmap F.age o

  let people_table = F.people_table
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
  module TFix = T.AllPasses  (* N.MainPasses *)
  module S = P

  type 'a repr =
    {again: unit -> 'a TFix.repr;
     last:  unit -> 'a S.repr}
  type 'a obs  = 'a S.obs

  (* record *)
  let people name age =
    {again = (fun () -> TFix.people (name.again ()) (age.again ()));
     last  = (fun () -> S.people (name.last ()) (age.last ())); }

  let names name =
    {again = (fun () -> TFix.names (name.again ()));
     last  = (fun () -> S.names (name.last ())); }

  (* projection *)
  let name r =
    {again = (fun () -> TFix.name (r.again ()));
     last  = (fun () -> S.name (r.last ())); }
  let age r =
    {again = (fun () -> TFix.age (r.again ()));
     last  = (fun () -> S.age (r.last ())); }

  (* data sources *)
  let people_table () = S.people_table ()




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


(* SQL translation with normal-form checking *)
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
  let people name age =
    {again = (fun () -> TFix.people (name.again ()) (age.again ()));
     last  = (fun () -> S.people (name.last ()) (age.last ()));
     form  = (fun () -> NF.people (name.form ()) (age.form ())); }

  let names name =
    {again = (fun () -> TFix.names (name.again ()));
     last  = (fun () -> S.names (name.last ()));
     form  = (fun () -> NF.names (name.form ())); }

  (* projection *)
  let name r =
    {again = (fun () -> TFix.name (r.again ()));
     last  = (fun () -> S.name (r.last ()));
     form  = (fun () -> NF.name (r.form ())); }
  let age r =
    {again = (fun () -> TFix.age (r.again ()));
     last  = (fun () -> S.age (r.last ()));
     form  = (fun () -> S.age (r.form ())); }

  (* data sources *)
  let people_table () = S.people_table ()



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

  (*
  let depth = ref 0
  let rec observe m =
    (* Printf.printf "observe: depth %d\n" !depth; *)
    incr depth;
    let r = if !depth > 10
      then S.observe (fun () -> (m ()).last ())
      else TFix.observe (fun () -> (m ()).again ()) in
    decr depth;
    r
  *)
end
