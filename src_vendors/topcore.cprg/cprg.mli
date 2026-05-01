(** {1 Introduction}

 [topcore-cprg] is a parser combinator library that.

	At the core of [topcore-cprg] are three things. First, the
	{i parser monad} {!code} *)

type 't code
(** ['t Cprg.code] *)

(** Secondly, the {i driver} parse function {!parse_string} *)

val parse_string : consume:[`All | `Prefix] -> 't code -> string -> ('t, string) result

(** And thirdly, the grammar (exists in the form of the parser
	monad aforementioned) which can be crafted by composing
	{i combinators} together. Example:

	{[ ]}

	Commonly-used combinators are *)

val take_while1 : (char -> bool) -> string code

val lift : ('a -> 'b) -> 'a code -> 'b code

val lift2 : ('a -> 'b -> 'c) -> 'a code -> 'b code -> 'c code

val fix : ('t code -> 't code) -> 't code
(** [Cprg.fix] is a decorator for writing recursive parser
	definition.
		
	Due to how OCaml's syntax work, you can't simply write a
	recursive parser with let-rec. [Cprg.fix] emulates let-rec
	on a monad level. *)

val char : char -> char code

val charset : string -> char code

val take_while : (char -> bool) -> string code

val map : 'a code -> ('a -> 'b) -> 'b code
(** [Cprg.map] is

	Mechanically, [Cprg.map] is a flip of [Cprg.lift] *)

val either : 't code -> 't code -> 't code

val seq : 'a code -> 'b code -> ('a * 'b) code

val seqr : unit code -> 't code -> 't code

val seql : 't code -> unit code -> 't code

val discard_first : 't code -> 't code -> 't code

val discard_second : 't code -> 't code -> 't code

val peek_char : char option code

val peek_char_fail : char code

val end_of_input : unit code

val bind : 'a code -> ('a -> 'b code) -> 'b code

val product : 'a code -> 'b code -> ('a * 'b) code

val return : 't -> 't code
(** [Cprg.return v] *)

val fail : string -> _ code
(** [Cprg.fail errormsg] *)

module Syntax :
	sig

	val ( <|> ) : 't code -> 't code -> 't code
  (** Infix operator [<|>], like operator [or], is an alias for [Cprg.either]. *)

	val ( or ) : 't code -> 't code -> 't code
  (** Infix operator [or], like operator [<|>], is an alias for [Cprg.either]. *)

	val ( *. ) : 'a code -> 'b code -> ('a * 'b) code

  val ( +> ) : unit code -> 't code -> 't code
  (** alias of [seqr] *)

  val ( <+ ) : 't code -> unit code -> 't code

	val ( <*  ) : 't code -> _ code -> 't code
  (** Infix operator [<*] is an alias for [Cprg.seql]. *)

	val (  *> ) : _ code -> 't code -> 't code
  (** Infix operator [*>] is an alias for [Cprg.seql]. *)

	val ( >>| ) : 'a code -> ('a -> 'b) -> 'b code

	val ( $ ) : 'a code -> ('a -> 'b) -> 'b code

	val ( <$> ) : ('a -> 'b) -> 'a code -> 'b code

  val ( ~- ) : _ code -> unit code
	
	val ( let* ) : 'a code -> ('a -> 'b code) -> 'b code

	val ( and* ) : 'a code -> 'b code -> ('a * 'b) code

	end
