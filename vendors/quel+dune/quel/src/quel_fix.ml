open Quel_sym
open Quel_norm
open Quel_sql



module rec Fix : (SymanticsL with type 'a obs = 'a GenSQL.obs) = struct

  module TFix = ForFor(ForWhere(ForYield(WhereFor(WhereWhere(Fix)))))
  module T = GenSQL

  type 'a repr =
    {again: unit -> 'a TFix.repr;
     last:  unit -> 'a T.repr}
  type 'a obs  = 'a T.obs

  let binop op1 op2 x y = {again = (fun () -> op1 (x.again ()) (y.again ()));
                           last  = (fun () -> op2 (x.last ()) (y.last ()));}

  let int    n = {again = (fun () -> TFix.int n);
                  last  = (fun () -> T.int n)}
  let float  f = {again = (fun () -> TFix.float f);
                  last  = (fun () -> T.float f)}
  let bool   b = {again = (fun () -> TFix.bool b);
                  last  = (fun () -> T.bool b)}
  let string s = {again = (fun () -> TFix.string s);
                  last  = (fun () -> T.string s)}

  let (+%)  x y  = binop (TFix.(+%)) (T.(+%)) x y
  let (-%)  x y  = binop (TFix.(-%)) (T.(-%)) x y
  let ( *%) x y  = binop (TFix.( *%)) (T.( *%)) x y
  let (/%)  x y  = binop (TFix.(/%)) (T.(/%)) x y

  let (+%.)  x y = binop (TFix.(+%.)) (T.(+%.)) x y
  let (-%.)  x y = binop (TFix.(-%.)) (T.(-%.)) x y
  let ( *%.) x y = binop (TFix.( *%.)) (T.( *%.)) x y
  let (/%.)  x y = binop (TFix.(/%.)) (T.(/%.)) x y

  let (>%)  x y  = binop (TFix.(>%)) (T.(>%)) x y
  let (<%)  x y  = binop (TFix.(<%)) (T.(<%)) x y
  let (=%)  x y  = binop (TFix.(=%)) (T.(=%)) x y

  let (>%.) x y  = binop (TFix.(>%.)) (T.(>%.)) x y
  let (<%.) x y  = binop (TFix.(<%.)) (T.(<%.)) x y
  let (=%.) x y  = binop (TFix.(=%.)) (T.(=%.)) x y

  let (>&)  x y  = binop (TFix.(>&)) (T.(>&)) x y
  let (<&)  x y  = binop (TFix.(<&)) (T.(<&)) x y
  let (=&)  x y  = binop (TFix.(=&)) (T.(=&)) x y

  let (>@)  x y  = binop (TFix.(>@)) (T.(>@)) x y
  let (<@)  x y  = binop (TFix.(<@)) (T.(<@)) x y
  let (=@)  x y  = binop (TFix.(=@)) (T.(=@)) x y

  let (!%)  x    = {
    again = (fun () -> TFix.(!%) (x.again ()));
    last  = (fun () -> T.(!%) (x.last ()))}

  let (&%)  x y  = binop (TFix.(&%)) (T.(&%)) x y
  let (|%)  x y  = binop (TFix.(|%)) (T.(|%)) x y

  let if_ b x y = {again = (fun () -> TFix.(if_) (b.again ())
                               (fun () -> (x ()).again ())
                               (fun () -> (y ()).again ()));
                   last  = (fun () -> T.(if_) (b.last ())
                               (fun () -> (x ()).last ())
                               (fun () -> (y ()).last ()))}

  let lam f = {
    again = (fun () ->
        TFix.lam (fun x ->
            let r = f {again = (fun () -> x);
                       last  = (fun () -> failwith "illegal call: lam 1")}
            in r.again ()));
    last  = (fun () ->
        T.lam (fun x ->
            let r = f {again = (fun () -> failwith "illegal call: lam 2");
                       last  = (fun () -> x)}
            in r.last ()));
  }

  let app x y = {
    again = (fun () -> TFix.app (x.again ()) (y.again ()));
    last  = (fun () -> T.app (x.last ()) (y.last ())) }


  let foreach src body = {
    again = (fun () -> TFix.foreach (fun () -> (src ()).again ()) (fun x ->
        let r = body {again = (fun () -> x);
                      last  = (fun () -> failwith "illegal call: foreach 1");}
            in r.again ()));
    last  = (fun () -> T.foreach (fun () -> (src ()).last ()) (fun x ->
        let r = body {again = (fun () -> failwith "illegal call: foreach 2");
                      last  = (fun () -> x);}
        in r.last ()));
  }

  let where test body = {
    again = (fun () -> TFix.where (test.again ()) (fun () ->
        let r = body ()
        in r.again ()));
    last  = (fun () -> T.where (test.last ()) (fun () ->
        let r = body ()
        in r.last ()))}

  let yield x = {
    again = (fun () -> TFix.yield (x.again ()));
    last  = (fun () -> T.yield (x.last ())); }

  let nil () = {
    again = (fun () -> TFix.nil ());
    last  = (fun () -> T.nil ()); }

  let exists x = {
    again = (fun () -> TFix.exists (x.again ()));
    last  = (fun () -> T.exists (x.last ())); }

  let (@%) x y = {
    again = (fun () -> TFix.(@%) (x.again ()) (y.again ()));
    last  = (fun () -> T.(@%) (x.last ()) (y.last ())); }

  let table (name,data) = failwith "E"

  let depth = ref 0
  let rec observe m =
    Printf.printf "observe: depth %d\n" !depth;
    incr depth;
    let r = if !depth > 10
      then T.observe (fun () -> (m ()).last ())
      else TFix.observe (fun () -> (m ()).again ()) in
    decr depth;
    r
end
