(* Examples *)

(*
#load "quel.cma";;
#load "schema_tlinq.cma";;
*)
open Schema_tlinq

(*--------------------------------------------------------------------*)
(* Queries *)

module GetAge(S:SYM_SCHEMA) = struct
  open S
  let people_table = table ("people", people_table ())

  let res = lam (fun s ->
      foreach (fun () -> people_table) @@ fun u ->
      where ((name u) =@ s) @@ fun () ->
      yield (age u))
end

module Range(S:SYM_SCHEMA) = struct
  open S
  let people_table = table ("people", people_table ())

  let res = lam (fun a -> lam (fun b ->
      foreach (fun () -> people_table) @@ fun w ->
      where (((a <% (age w)) |% (a =% (age w))) &%
             ((age w) <% b)) @@ fun () ->
      yield @@ names (name w)))
end

module Compose(S:SYM_SCHEMA) = struct
  open S
  module M1 = GetAge(S)
  module M2 = Range(S)

  let compose = lam (fun s -> lam (fun t ->
      foreach (fun () -> app M1.res s) @@ fun a ->
      foreach (fun () -> app M1.res t) @@ fun b ->
      app (app M2.res a) b))

  let res = app (app compose (string "Edna")) (string "Bert")

  let observe = observe
end


(*--------------------------------------------------------------------*)
(* Evaluation with R *)

(* Auxiliary printers *)
let rec print_names = function
  | [] -> ""
  | (o::os) -> "<name=" ^ o#name ^ ">; " ^ print_names os
;;

let module M = Compose(R) in
print_names @@ M.observe (fun () -> M.res)
(* "<name=Cora>; <name=Drew>; <name=Edna>; " *)


(*--------------------------------------------------------------------*)
(* Normalizations *)

(* before the normalization *)
let module M = Compose(P) in
  print_endline @@ M.observe (fun () -> M.res)
(*
  (fun x ->
   fun y ->
     foreach (fun () ->
       (fun z ->
          foreach (fun () -> table "people") (fun u ->
            where (u.name = z) (fun () -> yield (u.age))))
          x)
       (fun z ->
       foreach (fun () ->
         (fun u ->
            foreach (fun () -> table "people") (fun v ->
              where (v.name = u) (fun () -> yield (v.age))))
            y)
         (fun u ->
         (fun v ->
            fun w ->
              foreach (fun () -> table "people") (fun x6 ->
                where ((v < x6.age || v = x6.age) && x6.age < w) (fun () ->
                  yield <name=(x6.name)>)))
            z  u)))
   Edna  Bert
*)

(* after the normalization *)
let module M = Compose(FixP) in
  print_endline @@ M.observe (fun () -> M.res)

(*
  foreach (fun () -> table "people") (fun x ->
  foreach (fun () -> table "people") (fun y ->
    foreach (fun () -> table "people") (fun z ->
      where
        (x.name = Edna &&
           (y.name = Bert &&
              ((x.age < z.age || x.age = z.age) && z.age < y.age)))
        (fun () -> yield ((z.name).name)))))

*)



(*--------------------------------------------------------------------*)
(* SQL translations *)


(* Generate SQL string *)
let module M = Compose(FixGenSQL)
  in M.observe (fun () -> M.res)
(* "SELECT z.name AS name
    FROM people AS x, people AS y, people AS z
    WHERE true
      AND y.name = 'Bert'
      AND (x.age < z.age OR x.age = z.age)
      AND z.age < y.age
      AND x.name = 'Edna'"

 name
------
 Cora
 Drew
 Edna
(3 rows)
*)



(*--------------------------------------------------------------------*)
(* Performance test *)

let avg l = (List.fold_left (+.) 0.0 l) /. float(List.length l)

let r =
  let module M = Compose(FixP) in
  let perform () : float =
    let s = Sys.time () in
    ignore (M.observe (fun () -> M.res));
    Sys.time () -. s
  in let rec loop (data:float list) = function
    | 0 -> data
    | n -> loop ((perform ())::data) (n-1)
  in loop [] 100
in avg r

(* AllPasses * 10 times:
- : float = 0.324207559999999839
       ---> 324.20756 milliseconds
       ---> 324207.56 microseconds
*)
(* AllPasses * NF checking:
 - : float = 0.0066767300000000005
        ---> 6.67673 milliseconds
        ---> 6676.73 microseconds
*)

(* MainPasses * 10 times:
- : float = 0.000486490000000001097
       ---> 0.48649 milliseconds
       ---> 486.49  microseconds
)

(* MainPasses * NF checking:
- : float = 0.000178970000000000518
       ---> 0.17897 milliseconds
       ---> 178.97  microseconds
*)
