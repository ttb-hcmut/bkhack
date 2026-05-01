(*
 * Symantics interfaces
 *)

(* Base Symantics *)
module type Symantics_base = sig
  type 'a repr  (* representation type *)

  (* lifting constants *)
  val int     : int    -> int repr
  val bool    : bool   -> bool repr
  val string  : string -> string repr

  (* arithmetics *)
  val (+%)    : int repr -> int repr -> int repr
  val (-%)    : int repr -> int repr -> int repr
  val ( *%)   : int repr -> int repr -> int repr
  val (/%)    : int repr -> int repr -> int repr
  (* int comparison *)
  val (>%)    : int repr -> int repr -> bool repr
  val (<%)    : int repr -> int repr -> bool repr
  val (=%)    : int repr -> int repr -> bool repr
  (* bool comparison *)
  val (>&)    : bool repr -> bool repr -> bool repr
  val (<&)    : bool repr -> bool repr -> bool repr
  val (=&)    : bool repr -> bool repr -> bool repr
  (* string comparison *)
  val (>@)    : string repr -> string repr -> bool repr
  val (<@)    : string repr -> string repr -> bool repr
  val (=@)    : string repr -> string repr -> bool repr
  (* logical operators *)
  val (!%)    : bool repr -> bool repr
  val (&%)    : bool repr -> bool repr -> bool repr
  val (|%)    : bool repr -> bool repr -> bool repr

  (* condition *)
  val if_     : bool repr -> (unit -> 'a repr) -> (unit -> 'a repr) -> 'a repr
  (* lambda abstract *)
  val lam     : ('a repr -> 'b repr) -> ('a -> 'b) repr
  (* application *)
  val app     : ('a -> 'b) repr -> 'a repr -> 'b repr

  type 'a obs                           (* observation *)
  val observe : (unit -> 'a repr) -> 'a obs
end

(* Float *)
module type Symantics_float = sig
  include Symantics_base

  val float   : float -> float repr
  (* arithmetics *)
  val (+%.)   : float repr -> float repr -> float repr
  val (-%.)   : float repr -> float repr -> float repr
  val ( *%.)  : float repr -> float repr -> float repr
  val (/%.)   : float repr -> float repr -> float repr

  (* float comparison *)
  val (>%.)   : float repr -> float repr -> bool repr
  val (<%.)   : float repr -> float repr -> bool repr
  val (=%.)   : float repr -> float repr -> bool repr
end

(* Compose base and float *)
module type Symantics = sig
  include Symantics_float
end

(* Symantics with list operations *)
module type SymanticsL = sig
  include Symantics

  (* comprehension *)
  val foreach : (unit -> 'a list repr) ->
                ('a repr ->  'b list repr) -> 'b list repr
  (* condition *)
  val where   :  bool repr -> (unit -> 'a list repr) -> 'a list repr
  (* yield singleton list *)
  val yield   : 'a repr ->  'a list repr
  (* empty list *)
  val nil     :  unit -> 'a list repr
  (* not empty *)
  val exists  :  'a list repr ->  bool repr
  (* union list *)
  val (@%)    : 'a list repr -> 'a list repr -> 'a list repr

  (* the table constructor which take a table name and table contents *)
  val table : (string * 'a list) -> 'a list repr
end

module type SymanticsL' = sig
  include SymanticsL

  val limit   : int -> int -> (unit -> 'a list repr) -> 'a list repr
end
