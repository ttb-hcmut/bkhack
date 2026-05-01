(* Grouping constructs *)

(*
#load "quel.cma";;
#load "schema1.cma";;
*)
open Quel_sym
open Quel_r
open Schema1

(* Symantics for QueLG -----------------------------------------------*)
module type SymanticsG = sig
  include SymanticsL

  (* sorts of keys *)
  type constk
  type sumk

  type ('a,'b,'key) grepr
  type ('a,'b,'key) gres
  type ('a,'b,'groupkeys,'reskeys) coll

  (* sequence of expressions to group by *)
  type 'a gb_sequence
  type 'a gb_key_sequence
  (* type 'a gb_key             the key to group by *)
  val seq_one  : 'a repr -> ('a * unit) gb_sequence
  val seq_next : 'a repr -> 'b gb_sequence -> ('a *'b) gb_sequence
  val seq_decon : (('a,'a,constk) grepr -> 'b gb_key_sequence -> 'w) ->
                  ('a * 'b) gb_key_sequence -> 'w

  val group : 'gk gb_sequence ->
    ('gk gb_key_sequence -> ('a,'b,'res) gres) ->
      ('a,'b,'gk,'res) coll list repr

  val having : (bool,'b1,'k1) grepr ->
               (unit -> ('a,'b2,'k2) gres) -> ('a,'b1*'b2,'k1*'k2) gres
  val gyield : ('a,'b,'key) grepr -> ('a,'b,'key) gres

  val gint    : int    -> (int,int,constk) grepr
  val gbool   : bool   -> (bool,bool,constk) grepr
  val gstring : string -> (string,string,constk) grepr

  val (+$) : (int,'b1,'k1) grepr -> (int,'b2,'k2) grepr ->
    (int,'b1*'b2,'k1*'k2) grepr
  val (<$) : ('a,'b1,'k1) grepr -> ('a,'b2,'k2) grepr ->
    (bool,'b1*'b2,'k1*'k2) grepr
  val (>$) : ('a,'b1,'k1) grepr -> ('a,'b2,'k2) grepr ->
    (bool,'b1*'b2,'k1*'k2) grepr

  (* other primitives
  val (-$) : int aggr repr -> int aggr repr -> int aggr repr
  val (=$) : 'a aggr repr -> 'a aggr repr -> bool aggr repr
  val ($!) : bool aggr repr -> bool aggr repr
  val (&$) : bool aggr repr -> bool aggr repr -> bool aggr repr
  *)

  (* aggregation functions *)
  val sum : int repr -> (int,int,sumk) grepr
  val gpair : ('a,'b1,'k1) grepr -> ('b,'b2,'k2) grepr ->
              ('a * 'b,'b1*'b2,'k1*'k2) grepr

end






(* The implementation ------------------------------------------------*)

module RG = struct
  include RL

  (* can be made generic and extensible, do it later *)
  type constk1
  type sumk1

  type ('a,'sort) aggr =
    | Aconst : 'a  -> ('a,constk1) aggr
    | Asum   : int -> (int,sumk1) aggr

  let ag_observe : type a sort. (a,sort) aggr -> a = function
  | Aconst x -> x
  | Asum   x -> x

  let ag_next : type a sort.
    (a,sort) aggr -> (a,sort) aggr -> (a,sort) aggr = fun x y ->
    match (x,y) with
    | (_,Aconst x)     -> Aconst x
    | (Asum x, Asum y) -> Asum (x+y)

  type ('a,'sort) tuple =
    | Tone : ('a,'sort) aggr -> ('a,'sort) tuple
    | Ttwo : ('a,'s1) tuple * ('b,'s2) tuple -> ('a*'b,'s1*'s2) tuple

  let rec tu_observe : type a sort. (a,sort) tuple -> a = function
    | Tone x -> ag_observe x
    | Ttwo (x,y) -> (tu_observe x, tu_observe y)

  let [@warning "-8"] rec tu_next : type a sort. (a,sort) tuple -> (a,sort) tuple -> (a,sort) tuple = fun x y ->
    match (x,y) with
    | (Tone x, Tone y) -> Tone (ag_next x y)
  | (Ttwo (x1,x2), Ttwo(y1,y2)) -> Ttwo (tu_next x1 y1, tu_next x2 y2)
  (* The pattern-matching is actually exhaustive! *)

  type ('a,'b,'sort) grepr1 =
      Grepr : ('b,'sort) tuple * ('b -> 'a option) -> ('a,'b,'sort) grepr1

  let gr_observe : ('a,'b,'sort) grepr1 -> 'a option =
    function
    Grepr (arg,prj) -> prj (tu_observe arg)

  let gr_next : ('a,'b,'sort) grepr1 -> ('a,'b,'sort) grepr1 ->
    ('a,'b,'sort) grepr1 =
    function (Grepr (a,_)) -> function (Grepr (b,p)) ->
      Grepr (tu_next a b,p)

  let gr_compose : ('a1 -> 'a2 -> 'a) ->
  ('a1,'b1,'sort1) grepr1 -> ('a2,'b2,'sort2) grepr1 ->
    ('a,'b1*'b2,'sort1*'sort2) grepr1 =
    fun f (Grepr (b1,p1)) (Grepr (b2,p2)) ->
      Grepr (Ttwo (b1,b2),
             (fun (b1,b2) ->
                match (p1 b1,p2 b2) with
                | (Some a1, Some a2) -> Some (f a1 a2)
                | _ -> None))


  let gr_const : 'a -> ('a,'a,constk1) grepr1 = fun x ->
    Grepr (Tone (Aconst x),fun x -> Some x)



  type ('a,'b,'groupkeys,'reskeys) coll1 =
    {grouping : 'groupkeys;
     coll_res : ('a,'b,'reskeys) grepr1}

  (* final observation *)
  let coll_observe : ('a,'b,'groupkeys,'reskeys) coll1 -> 'a option = fun coll ->
    gr_observe coll.coll_res

  let coll_next :
    ('a,'b,'groupkeys,'reskeys) coll1 -> ('a,'b,'groupkeys,'reskeys) coll1 ->
    ('a option * ('a,'b,'groupkeys,'reskeys) coll1) = fun c1 c2 ->
    if c1.grouping = c2.grouping (* the same group *)
    then (None,{c1 with coll_res = gr_next c1.coll_res c2.coll_res})
    else (gr_observe c1.coll_res,c2)

  (* the coll list concatenated by foreach, so we should sort it here *)
  let final_observe : ('a,'b,'groupkeys,'reskeys) coll1 list -> 'a list =
    let rec final_observe_internal : ('a,'b,'groupkeys,'reskeys) coll1 list -> 'a list =
      function
      | []   -> []
      | [x]  ->
        begin
          match coll_observe x with
          | None   -> []
          | Some x -> [x]
        end
      | h1::h2::t ->
        begin
          match coll_next h1 h2 with
          | (None,h) -> final_observe_internal (h::t)
          | (Some x,h) -> x :: final_observe_internal (h::t)
        end
    in fun vs ->
      (* coll has a function abstraction, so it can't comparison its values direcly
         to avoid failure with function comparison, we use grouping field
         and then sort coll values *)
      let vs' = List.sort (fun x y -> if x.grouping > y.grouping then 1 else -1) vs in
      final_observe_internal vs'

  let having1 : (bool,'b1,'sort1) grepr1 -> (unit -> ('a,'b2,'sort2) grepr1) ->
    ('a,'b1*'b2,'sort1*'sort2) grepr1 =
    fun (Grepr (barg,bp)) body ->
      match body () with (Grepr (arg,p)) ->
        Grepr (Ttwo (barg,arg),
               (fun (b1,b2) ->
                  match bp b1 with
                  | Some true -> p b2
                  | _         -> None))







  type constk = constk1
  type sumk   = sumk1

  type ('a,'b,'key) grepr = ('a,'b,'key) grepr1
  type ('a,'b,'key) gres  = ('a,'b,'key) grepr1
  type ('a,'b,'groupkeys,'reskeys) coll =
    ('a,'b,'groupkeys,'reskeys) coll1

  (* sequence of expressions to group by *)
  type 'a gb_sequence     = 'a
  type 'a gb_key_sequence = 'a
  let seq_one  x   = (x,())
  let seq_next h t = (h,t)
  let seq_decon : (('a,'a,constk) grepr -> 'b gb_key_sequence -> 'w) ->
    ('a * 'b) gb_key_sequence -> 'w = fun k (h,t) ->
    k (gr_const h) t

  let group : 'gk gb_sequence ->
    ('gk gb_key_sequence -> ('a,'b,'res) gres) ->
    ('a,'b,'gk,'res) coll list repr = fun seq k ->
    [{grouping = seq; coll_res = k seq}]

  let having : (bool,'b1,'k1) grepr ->
    (unit -> ('a,'b2,'k2) gres) -> ('a,'b1*'b2,'k1*'k2) gres
    = having1

  let gyield : ('a,'b,'key) grepr -> ('a,'b,'key) gres = fun x -> x

  let gint    : int    -> (int,int,constk) grepr = gr_const
  let gbool   : bool   -> (bool,bool,constk) grepr = gr_const
  let gstring : string -> (string,string,constk) grepr = gr_const

  let (+$) : (int,'b1,'k1) grepr -> (int,'b2,'k2) grepr ->
    (int,'b1*'b2,'k1*'k2) grepr
    = fun g1 g2 -> gr_compose (fun x y -> (x+y)) g1 g2

  let (<$) : ('a,'b1,'k1) grepr -> ('a,'b2,'k2) grepr ->
    (bool,'b1*'b2,'k1*'k2) grepr
    = fun g1 g2 -> gr_compose (fun x y -> (x<y)) g1 g2

  let (>$) : ('a,'b1,'k1) grepr -> ('a,'b2,'k2) grepr ->
    (bool,'b1*'b2,'k1*'k2) grepr
    = fun g1 g2 -> gr_compose (fun x y -> (x>y)) g1 g2

  (* val the : 'a group repr -> ('a,'t) label -> 't aggr repr *)
  let sum : int repr -> (int,int,sumk) grepr
    = fun x -> Grepr (Tone (Asum x),fun x -> Some x)

  let gpair : ('a,'b1,'k1) grepr -> ('b,'b2,'k2) grepr ->
    ('a * 'b,'b1*'b2,'k1*'k2) grepr
    = fun g1 g2 -> gr_compose (fun x y -> (x,y)) g1 g2
end







(* Schema ------------------------------------------------------------*)
(* We use the schema in `schema1.ml` *)
module type SYM_SCHEMA = sig
  include SymanticsG
  include SCHEMA  with type 'a repr := 'a repr
end

module R = struct
  include RG
  include (R_schema : SCHEMA with type 'a repr := 'a repr)
end


(* Examples ----------------------------------------------------------*)

module Q4(S:SYM_SCHEMA) = struct
  open S
  let products = table("products", products ())
  let orders   = table("orders", orders ())

  let res =
    foreach (fun () -> orders) @@ fun o ->
    foreach (fun () -> products) @@ fun p ->
    where (((opid o) =% (pid p)) &% ((price p) >% int 100)) @@ fun () ->
    group (seq_one (price p)) @@
    seq_decon (fun gprice _ ->
    having (sum ((price p) *% (qty o)) >$ (gint 500)) @@ fun () ->
    gyield (gpair gprice (sum ((price p) *% (qty o)))))

  let observe = observe
end


let () = ignore @@
  let module M = Q4(R) in
  R.final_observe M.res
(* - : (int * int) list = [(500, 12500); (1000, 55000)] *)

(*
The SQL query corresponding to the above:

SELECT p.price, SUM(p.price * o.qty)
FROM products AS p, orders AS o
WHERE p.pid = o.pid
AND p.price > 100 /* HDD is excluded */
GROUP BY p.price
HAVING SUM(p.price * o.qty) > 500;  /* a group of price 150 is excluded */

 price |  sum
-------+-------
  1000 | 55000
   500 | 12500
*)
