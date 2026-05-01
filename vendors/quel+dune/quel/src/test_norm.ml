(* Testing normalization rules *)
(*
#load "quel.cma";;
#load "schema1.cma";;
*)

open Quel_sym
open Quel_norm
open Quel_r
open Quel_p


(*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  Stage 1
  \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
*)

(* --------------------------------------
   1-1. [AbsBeta]
   (\x.M) N ---> N[x := M]
   ------------------------------------*)
module N11(S:SymanticsL) = struct
  open S
  let t1 = observe @@ fun () ->
    app (lam (fun x -> x +% (int 1))) (int 2)
end

(* equivalence checking *)
let r1 = let module M = N11(RL) in M.t1 in
let r2 = let module M = N11(AbsBeta(RL)) in M.t1 in
r1 = r2
(* - : bool = true *)

(* printing without AbsBeta rule *)
let _ = let module M = N11(PL) in
  print_endline M.t1
(* (fun x -> x + 1)  2 *)

(* printing with AbsBeta rule *)
let _ = let module M = N11(AbsBeta(PL)) in
  print_endline M.t1
(* 2 + 1 *)


(* --------------------------------------
   1-2. [RecordBeta]
   ------------------------------------*)
module N12(S:Schema1.SYM_SCHEMA) = struct
  open S
  let products = table ("products", products ())
  let q1 = observe @@ fun () ->
    foreach (fun () -> products) (fun x ->
      yield @@ name (product (pid x) (name x) (price x)))

  let q2 = observe @@ fun () ->
    foreach (fun () -> products) (fun x ->
      yield @@ name x)
end

let r1 = let module M = N12(Schema1.R) in M.q1 in
let r2 = let module M = N12(Schema1.RecordBeta(Schema1.R)) in M.q1 in
r1 = r2
(* - : bool = true *)

(* printing without RecordBeta rule *)
let _ = let module M = N12(Schema1.P) in
  print_endline M.q1
(*
  foreach (fun () -> table "products") (fun x ->
  yield
    (<pid=(x.pid);name=(x.name);price=(x.price);category=(x.category)>.name))
*)

(* printing with RecordBeta rule *)
let _ = let module M = N12(Schema1.RecordBeta(Schema1.P)) in
  print_endline M.q1
(* foreach (fun () -> table "products") (fun x -> yield (x.name)) *)


(* --------------------------------------
   1-3. [ForYield]
   foreach (fun () -> yield M) (fun x -> N)
   ---> N[x := M]
   ------------------------------------*)
module N13(S:SymanticsL) = struct
  open S
  (* simple case *)
  let q1 = observe @@ fun () ->
    foreach (fun () -> yield (int 10))
	    (fun x -> yield x)
  (* inner yield in an abstraction *)
  let q2 = observe @@ fun () ->
    lam (fun x ->
	 foreach (fun () -> yield x)
		 (fun y -> yield y))
  (* inner yield in a comprehension *)
  let q3 = observe @@ fun () ->
    foreach (fun () ->
        foreach (fun () -> yield (int 1)) (fun x -> yield x))
      (fun y ->
        yield y)
end

let r1 = let module M = N13(RL) in M.q1 in
let r2 = let module M = N13(ForYield(RL)) in M.q1 in
r1 = r2
(* - : bool = true *)

let r = let module M = N13(ForYield(PL)) in M.q1
in print_endline r
(* yield 10 *)

let r = let module M = N13(ForYield(PL)) in M.q2 in
print_endline r
(* fun x -> yield x *)

let r = let module M = N13(ForYield(PL)) in M.q3
in print_endline r
(* yield 1 *)


(* --------------------------------------
   1-4. [ForFor]
   foreach (fun () -> yield M) (fun x -> N)
   ---> N[x := M]
   ------------------------------------*)
module N14(S:SymanticsL) = struct
  open S
  let q1 = observe @@ fun () ->
    foreach (fun () ->
        foreach (fun () -> yield (int 1)) (fun x -> yield x))
      (fun y ->
         yield (y +% (int 10)))

  let q2 = observe @@ fun () ->
    foreach (fun () ->
        foreach (fun () ->
            foreach (fun () -> yield (int 1)) (fun x ->
                yield x)) (fun y ->
            yield y)) (fun z ->
        yield z)
end

let r1 = let module M = N14(RL) in M.q1 in
let r2 = let module M = N14(ForFor(RL)) in M.q1 in
r1 = r2
(* - : bool = true *)

let r = let module M = N14(ForFor(PL)) in M.q1
in print_endline r
(*
foreach (fun () -> yield 1) (fun x ->
foreach (fun () -> yield x) (fun y -> yield (y + 10)))
*)

(* apply ForFor once *)
let r = let module M = N14(ForFor(PL)) in M.q2
in print_endline r
(*
  foreach (fun () ->
  foreach (fun () -> yield 1) (fun x ->
    foreach (fun () -> yield x) (fun y -> yield y)))
  (fun x -> yield x)
*)

(* apply ForFor twice *)
let r = let module M = N14(ForFor(ForFor(PL))) in M.q2
in print_endline r
(*
  foreach (fun () -> yield 1) (fun x ->
  foreach (fun () -> foreach (fun () -> yield x) (fun y -> yield y)) (fun y
    -> yield y))
*)

(* apply ForFor three times *)
let r = let module M = N14(ForFor(ForFor(ForFor(PL)))) in M.q2
in print_endline r
(*
  foreach (fun () -> yield 1) (fun x ->
  foreach (fun () -> yield x) (fun y ->
    foreach (fun () -> yield y) (fun z -> yield z)))
*)



(* 1-5. [ForWhere]
   foreach (fun () ->
   where L (fun () -> M) (fun x -> N)
   ---> where L (fun () ->
        foreach (fun () -> M) (fun x -> N))
 *)
module N15(S:SymanticsL) = struct
  open S
  let q1 = observe @@ fun () ->
    foreach (fun () -> where (bool true) (fun () -> yield (int 1)))
      (fun x ->
    yield x)

  let q2 = observe @@ fun () ->
    foreach (fun () -> yield (int 1)) (fun x ->
    foreach (fun () ->
            where (x =% (int 1)) (fun () -> yield x))
	  (fun y ->
    yield (y +% (int 10))))
end

let r1 = let module M = N15(RL) in M.q1 in
let r2 = let module M = N15(ForWhere(RL)) in M.q1 in
r1 = r2
(* - : bool = true *)

let r = let module M = N15(ForWhere(PL)) in M.q1
in print_endline r
(* where true (fun () -> foreach (fun () -> yield 1) (fun x -> yield x)) *)

let r = let module M = N15(ForWhere(PL)) in M.q2
in print_endline r
(*
  foreach (fun () -> yield 1) (fun x ->
  where (x = 1) (fun () ->
    foreach (fun () -> yield x) (fun y -> yield (y + 10))))
*)



(* 1-6. [ForEmpty1]
   foreach (fun () -> nil ())
           (fun x -> N)
   ---> nil ()
*)
module N16(S:SymanticsL) = struct
  open S
  let q = nil ()
  let q1 = observe @@ fun () ->
    foreach (fun () -> nil ()) (fun x ->
      yield x)
end

let r1 = let module M = N16(RL) in M.q1 in
let r2 = let module M = N16(ForEmpty1(RL)) in M.q1 in
r1 = r2
(* - : bool = true *)

let r = let module M = N16(ForEmpty1(PL)) in M.q1
in print_endline r
(* [] *)



(* 1-7. [ForUnionAll1]
   foreach (fun () -> L @% M) (fun x () -> N)
   ---> foreach (fun () -> L)
                (fun x -> M)
        @%
        foreach (fun () -> L)
                (fun x -> N)
*)
module N17(S:SymanticsL) = struct
  open S
  let q1 = observe @@ fun () ->
    foreach (fun () -> yield (int 1) @% yield (int 2)) (fun x ->
        yield x)
end

let r1 = let module M = N17(RL) in M.q1 in
let r2 = let module M = N17(ForUnionAll1(RL)) in M.q1 in
r1 = r2
(* - : bool = true *)

let r = let module M = N17(ForUnionAll1(PL)) in M.q1
in print_endline r
(*
  foreach (fun () -> yield 1) (fun x -> yield x) @
  foreach (fun () -> yield 2) (fun x -> yield x)
*)


(* 1-8. [WhereTrue]
   where true (fun () -> L)
   ---> L
*)
module N18(S:SymanticsL) = struct
  open S
  let q1 = observe @@ fun () ->
    where (bool true) (fun () ->
    yield (int 1))
end

let r1 = let module M = N18(RL) in M.q1 in
let r2 = let module M = N18(WhereTrue(RL)) in M.q1 in
r1 = r2
(* - : bool = true *)

let r = let module M = N18(WhereTrue(PL)) in M.q1
in print_endline r
(* yield 1 *)


(* 1-9. [WhereFalse]
   where false (fun () -> L)
   ---> nil ()
*)
module N19(S:SymanticsL) = struct
  open S
  let q1 = observe @@ fun () ->
    where (bool false) (fun () ->
    yield (int 1))
end

let r1 = let module M = N19(RL) in M.q1 in
let r2 = let module M = N19(WhereFalse(RL)) in M.q1 in
r1 = r2
(* - : bool = true *)

let r = let module M = N19(WhereFalse(PL)) in M.q1
in print_endline r
(* [] *)


(*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  Stage 2
  \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
*)

(* 2-1. [ForUnionAll2]
   foreach (fun () -> L) (fun x -> M @% N)
   ---> foreach (fun () -> L)
                (fun x -> M)
        @%
        foreach (fun () -> L)
                (fun x -> N)
*)
module N21(S:SymanticsL) = struct
  open S
  (* a basic case *)
  let q1 = observe @@ fun () ->
    foreach (fun () -> yield (int 1)) (fun x ->
    (yield x) @% (yield (x +% (int 10))))

  (* nested cases *)
  let q2 = observe @@ fun () ->
    foreach (fun () -> yield (int 1)) (fun x ->
    yield x @% yield x @% yield x)

  let q3 x = foreach (fun () -> yield (int 1)) (fun y ->
      yield x @% yield y)
  let q4 = observe @@ fun () ->
    foreach (fun () -> yield (int 2)) (fun x ->
      q3 x @% q3 x)
end

let r1 = let module M = N21(RL) in M.q1 in
let r2 = let module M = N21(ForUnionAll2(RL)) in M.q1 in
r1 = r2
(* - : bool = true *)

(* Case 1 *)
let r = let module M = N21(ForUnionAll2(PL)) in M.q1
in print_endline r
(*
  foreach (fun () -> yield 1) (fun x -> yield x) @
  foreach (fun () -> yield 1) (fun x -> yield (x + 10))
*)

(* Case 2 *)
(* apply ForUnionAll2 rule once *)
let r = let module M = N21(ForUnionAll2(PL)) in M.q2
in print_endline r
(*
  foreach (fun () -> yield 1) (fun x -> yield x) @
  foreach (fun () -> yield 1) (fun x -> yield x @ yield x)
*)
(* apply ForUnionAll2 rule twice *)
let r = let module M = N21(ForUnionAll2(ForUnionAll2(PL))) in M.q2
in print_endline r
(*
foreach (fun () -> yield 1) (fun x -> yield x) @
  (foreach (fun () -> yield 1) (fun x -> yield x) @
     foreach (fun () -> yield 1) (fun x -> yield x))
*)

(* Case 3 *)
let r = let module M = N21(PL) in M.q4
in print_endline r
(*
  foreach (fun () -> yield 2) (fun x ->
  foreach (fun () -> yield 1) (fun y -> yield x @ yield y) @
    foreach (fun () -> yield 1) (fun y -> yield x @ yield y))
*)

let r = let module M =
  N21(ForUnionAll2(ForUnionAll2(ForUnionAll2(PL)))) in M.q4
in print_endline r
(* Union(@) is not in the body:
    (foreach (fun () -> yield 2) (fun x ->
   foreach (fun () -> yield 1) (fun y -> yield x)) @
   foreach (fun () -> yield 2) (fun x ->
     foreach (fun () -> yield 1) (fun y -> yield y)))
  @
  (foreach (fun () -> yield 2) (fun x ->
     foreach (fun () -> yield 1) (fun y -> yield x)) @
     foreach (fun () -> yield 2) (fun x ->
       foreach (fun () -> yield 1) (fun y -> yield y)))
*)



(* --------------------------------------
   2-2. [ForEmpty2]
   foreach (fun () -> L) (fun x -> nil ())
   ===> nil ()
   ------------------------------------*)
module N22(S:SymanticsL) = struct
  open S
  let q1 = observe @@ fun () ->
    foreach (fun () -> yield (int 1)) (fun x ->
      nil ())
end

let r1 = let module M = N22(RL) in M.q1 in
let r2 = let module M = N22(ForEmpty2(RL)) in M.q1 in
r1 = r2
(* - : bool = true *)

let r = let module M = N22(ForEmpty2(PL)) in M.q1
in print_endline r
(* [] *)


(* --------------------------------------
   2-3. [WhereEmpty]
   where L (fun () -> nil ())
   ===> nil ()
   ------------------------------------*)
module N23(S:SymanticsL) = struct
  open S
  let q1 = observe @@ fun () ->
    where (bool true)
	  (fun () -> nil ())

  let q2 = observe @@ fun () ->
    where (bool false)
	  (fun () -> nil ())
end

let r1 = let module M = N23(RL) in M.q1 in
let r2 = let module M = N23(WhereEmpty(RL)) in M.q1 in
r1 = r2
(* - : bool = true *)

let r = let module M = N23(WhereEmpty(PL)) in M.q1
in print_endline r
(* [] *)

let r = let module M = N23(WhereEmpty(PL)) in M.q2
in print_endline r
(* [] *)


(* --------------------------------------
   2-4. [WhereWhere]
   where L (fun () -> where M (fun () -> N))
   ===> where (L && M) (fun () -> N)
   ------------------------------------*)
module N24(S:SymanticsL) = struct
  open S
  let q1 = observe @@ fun () ->
    where ((int 1) <% (int 2)) (fun () ->
    where ((int 10) <% (int 20)) (fun () ->
    yield (int 100)))
end

let r1 = let module M = N24(RL) in M.q1 in
let r2 = let module M = N24(WhereWhere(RL)) in M.q1 in
r1 = r2
(* - : bool = true *)

let r = let module M = N24(WhereWhere(PL)) in M.q1
in print_endline r
(*
  where (1 < 2 && 10 < 20) (fun () -> yield 100)
*)



(* --------------------------------------
   2-5. [WhereFor]
   where L (fun () ->
   foreach (fun () -> M) (fun x -> N))
   ===> foreach (fun () -> M) (fun x ->
        where L (fun () -> N))
   ------------------------------------*)
module N25(S:SymanticsL) = struct
  open S
  let q1 = observe @@ fun () ->
    where ((int 1) <% (int 2)) (fun () ->
    foreach (fun () -> yield (int 1)) (fun x ->
    yield x))
end

let r1 = let module M = N25(RL) in M.q1 in
let r2 = let module M = N25(WhereFor(RL)) in M.q1 in
r1 = r2
(* - : bool = true *)

let r = let module M = N25(WhereFor(PL)) in M.q1
in print_endline r
(*
  foreach (fun () -> yield 1) (fun x -> where (1 < 2) (fun () -> yield x))
*)
