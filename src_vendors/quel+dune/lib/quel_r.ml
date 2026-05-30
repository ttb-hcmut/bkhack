(* The R interpreter *)

open Quel_sym

module R_base = struct
  type 'a repr = 'a

  let int n    = n
  let bool b   = b
  let string s = s

  let (+%)  = (+)
  let (-%)  = (-)
  let ( *%) = ( * )
  let (/%)  = (/)

  (* To use specific primitives, give type annotations *)
  let (>%) (e1:int repr) (e2:int repr) = e1 > e2
  let (<%) (e1:int repr) (e2:int repr) = e1 < e2
  let (=%) (e1:int repr) (e2:int repr) = e1 = e2

  let (>@) (e1:string repr) (e2:string repr) = e1 > e2
  let (<@) (e1:string repr) (e2:string repr) = e1 < e2
  let (=@) (e1:string repr) (e2:string repr) = e1 = e2

  let (>&) (e1:bool repr) (e2:bool repr) = e1 > e2
  let (<&) (e1:bool repr) (e2:bool repr) = e1 < e2
  let (=&) (e1:bool repr) (e2:bool repr) = e1 = e2

  let (!%)  = not
  let (&%) = (&&)
  let (|%) = (||)

  let if_ e e1 e2 = if e then e1 () else e2 ()

  let lam f = f
  let app e1 e2 = e1 e2

  type 'a obs = 'a repr
  let observe x = x ()
end

(* Float constructs *)
module R_float = struct
  include R_base

  let float f = f

  let (+%.)  = (+.)
  let (-%.)  = (-.)
  let (/%.)  = (/.)
  let ( *%.) = ( *.)

  let (>%.) (e1:float repr) (e2:float repr) = e1 > e2
  let (<%.) (e1:float repr) (e2:float repr) = e1 < e2
  let (=%.) (e1:float repr) (e2:float repr) = e1 = e2
end

module R = struct
  include R_float
end


(* The R interpreter with list and record *)
module RL = struct
  include R

  let rec foreach src body =
    match src () with
      [] -> []
    | (x::xs) -> (body x) @ (foreach (fun () -> xs) body)

  let where test body =
    if test then body () else []

  let yield x = [x]
  let nil ()  = []

  let exists = function
      [] -> false
    | _  -> true

  let (@%) e1 e2 = e1 @ e2

  let table (name, data) = data
end
