(* The P interpreter as a pretty-printer *)

open Quel_sym
open Format

(*
We use standard Format module to pretty-print
 http://caml.inria.fr/resources/doc/guides/format.en.html
 http://caml.inria.fr/pub/docs/manual-ocaml/libref/Format.html
*)
module P = struct
  (* representation type *)
  (* precedences:
   * http://caml.inria.fr/pub/docs/manual-ocaml/expr.html
   *  high         low
   *  12 <-------> 0
   *)
  type precedence = int
  type varcount   = int
  type 'a repr = precedence -> varcount -> formatter -> unit

  (* observation *)
  type 'a obs  = string
  let observe x = x () 0 0 str_formatter; flush_str_formatter ()

  (* auxiliary functions for printing *)
  let varnames = "xyzuvw"
  let varname : int -> string = function
    | i when i < String.length varnames ->
        String.make 1 @@ varnames.[i]
    | i -> "x" ^ string_of_int i
  let paren (ppf:formatter) : bool -> (formatter -> unit) -> unit = function
    | true -> fun x -> fprintf ppf "(%t)" x
    | _    -> fun x -> x ppf
  (* It is give type annotations to avoid the value restriction *)
  let print_infix pth pl pr op = fun e1 e2 -> fun (p:precedence) (v:varcount) (ppf:formatter) ->
    paren ppf (p > pth) @@
    fun ppf -> fprintf ppf "@[<2>%t@;%s@;%t@]" (e1 pl v) op (e2 pr v)
  (* application to some standard function *)
  let print_app_std op x = fun (p:precedence) (v:varcount) (ppf:formatter) ->
    paren ppf (p > 10) @@
    fun ppf -> fprintf ppf "@[<2>%s@;%t@]" op (x 11 v)

  (* constant constructors *)
  let int    n = fun p v ppf -> fprintf ppf "%d" n
  let float  f = fun p v ppf -> fprintf ppf "%f" f
  let bool   b = fun p v ppf -> fprintf ppf "%b" b
  let string s = fun p v ppf -> fprintf ppf "%s" s

  (* operators *)
  let (+%)   = print_infix 6 7 7 "+"
  let (-%)   = print_infix 6 7 7 "-"
  let ( *%)  = print_infix 7 8 8 "*"
  let (/%)   = print_infix 7 8 8 "/"

  let (+%.)  = print_infix 6 7 7 "+."
  let (-%.)  = print_infix 6 7 7 "-."
  let ( *%.) = print_infix 7 8 8 "*."
  let (/%.)  = print_infix 7 8 8 "/."

  let (>%)   = print_infix 3 4 4 ">"
  let (<%)   = print_infix 3 4 4 "<"
  let (=%)   = print_infix 3 4 4 "="

  let (>%.)   = print_infix 3 4 4 ">"
  let (<%.)   = print_infix 3 4 4 "<"
  let (=%.)   = print_infix 3 4 4 "="

  let (>&)   = print_infix 3 4 4 ">"
  let (<&)   = print_infix 3 4 4 "<"
  let (=&)   = print_infix 3 4 4 "="

  let (>@)   = print_infix 3 4 4 ">"
  let (<@)   = print_infix 3 4 4 "<"
  let (=@)   = print_infix 3 4 4 "="

  let (!%) x = fun p v ppf ->
    paren ppf (p > 10) @@
    fun ppf -> fprintf ppf "@[<2>not@;%t@]" (x 0 v)
  let (&%) = print_infix 2 3 3 "&&"
  let (|%) = print_infix 1 2 2 "||"

  let if_ e e1 e2 = fun p v ppf ->
    paren ppf (p > 0) @@
    fun ppf -> fprintf ppf "@[<2>if@;%t@;then@;%t@;else@;%t@]" (e p v) ((e1 ()) p v) ((e2 ()) p v)

  (* lambda abstraction and applications *)
  let lam f = fun p v ppf ->
    let vn  = varname v in
    paren ppf (p > 0) @@
    fun ppf ->
      fprintf ppf "@[<2>fun@;%s@;->@;%t@]" vn
        (f (fun _ _ ppf -> fprintf ppf "%s" vn) 0 (v+1))

  let app  = print_infix 10 10 11 ""

end

module PL = struct
  include P

  let foreach src body = fun p v ppf ->
    let vn  = varname v in
    paren ppf (p > 10) @@ fun ppf ->
    fprintf ppf "@[<2>foreach@;(fun@ ()@;->@;%t)@;(fun@;%s@;->@;%t)@]"
       (src () 0 v) vn (body (fun _ _ ppf -> fprintf ppf "%s" vn) 0 (v+1))

  let where test body = fun p v ppf ->
    paren ppf (p > 10) @@ fun ppf ->
    fprintf ppf "@[<2>where@;%t@;(fun@ ()@;->@;%t)@]"
         (test 11 v) (body () 0 v)

  let yield x = print_app_std "yield" x

  let nil () = fun p v ppf -> fprintf ppf "[]"
  let exists x = print_app_std "exists" x

  let (@%)   = print_infix 5 6 6 "@"

  let table (name,data) = fun p v ppf ->
    fprintf ppf "@[<1>table@;\"%s\"@]" name
end
