(** {1 Introduction}

 [topcore-cprg] is a parser combinator library that.

	At the core of [topcore-cprg] are three things. First, the
	{i parser monad} {!code} *)

type ('ctx, 't) code
(** ['t Cprg.code] *)

type normal

(** Secondly, the {i driver} parse function {!parse_string} *)

val parse_string : consume:[`All | `Prefix] -> (normal, 't) code -> string -> ('t, string) result

(** And thirdly, the grammar (exists in the form of the parser
	monad aforementioned) which can be crafted by composing
	{i combinators} together. Example:

	{[ ]}

	Commonly-used combinators are *)

val take_while1 : (char -> bool) -> (_, string) code

val lift : ('a -> 'b) -> ('ctx, 'a) code -> ('ctx, 'b) code

val lift2 : ('a -> 'b -> 'c) -> ('ctx, 'a) code -> (_, 'b) code -> ('ctx, 'c) code

type fixed

val fix : ((fixed, 't) code -> ('ctx, 't) code) -> ('ctx, 't) code
(** [Cprg.fix] is a decorator for writing recursive parser
	definition.
		
	Due to how OCaml's syntax work, you can't simply write a
	recursive parser with let-rec. [Cprg.fix] emulates let-rec
	on a monad level. *)

val char : char -> (_, char) code

val charset : string -> (_, char) code

val take_while : (char -> bool) -> (_, string) code

val map : ('ctx, 'a) code -> ('a -> 'b) -> ('ctx, 'b) code
(** [Cprg.map] is

	Mechanically, [Cprg.map] is a flip of [Cprg.lift] *)

val either : (normal, 't) code -> ('ctx, 't) code -> (normal, 't) code

val seq : ('ctx, 'a) code -> (_, 'b) code -> ('ctx, 'a * 'b) code

val seqr : ('ctx, unit) code -> (_, 't) code -> ('ctx, 't) code

val seql : ('ctx, 't) code -> (_, unit) code -> ('ctx, 't) code

val discard_first : ('ctx, 't) code -> (_, 't) code -> ('ctx, 't) code

val discard_second: ('ctx, 't) code -> (_, 't) code -> ('ctx, 't) code

val peek_char : (_, char option) code

val peek_char_fail : (_, char) code

val advance : int -> (_, unit) code

val end_of_input : (_, unit) code

val bind : ('ctx, 'a) code -> ('a -> ('ctx, 'b) code) -> ('ctx, 'b) code

val product : ('ctx, 'a) code -> (_, 'b) code -> ('ctx, ('a * 'b)) code

val return : 't -> (_, 't) code
(** [Cprg.return v] *)

val fail : string -> (_, _) code
(** [Cprg.fail errormsg] *)

module Syntax :
	sig

	val ( <|> ) : (normal, 't) code -> (_, 't) code -> (normal, 't) code
  (** Infix operator [<|>], like operator [or], is an alias for [Cprg.either]. *)

	val ( or ) : (normal, 't) code -> (_, 't) code -> (normal, 't) code
  (** Infix operator [or], like operator [<|>], is an alias for [Cprg.either]. *)

	val ( *. ) : ('ctx, 'a) code -> (_, 'b) code -> ('ctx, ('a * 'b)) code

  val ( +> ) : ('ctx, unit) code -> (_, 't) code -> ('ctx, 't) code
  (** alias of [seqr] *)

  val ( <+ ) : ('ctx, 't) code -> (_, unit) code -> ('ctx, 't) code

	val ( <*  ) : ('ctx, 't) code -> (_, _) code -> ('ctx, 't) code
  (** Infix operator [<*] is an alias for [Cprg.seql]. *)

	val (  *> ) : ('ctx, _) code -> (_, 't) code -> ('ctx, 't) code
  (** Infix operator [*>] is an alias for [Cprg.seql]. *)

	val ( >>| ) : ('ctx, 'a) code -> ('a -> 'b) -> ('ctx, 'b) code

	val ( $ ) : ('ctx, 'a) code -> ('a -> 'b) -> ('ctx, 'b) code

	val ( <$> ) : ('a -> 'b) -> ('ctx, 'a) code -> ('ctx, 'b) code

  val ( ~- ) : ('ctx, _) code -> ('ctx, unit) code
	
	val ( let* ) : ('ctx, 'a) code -> ('a -> ('ctx, 'b) code) -> ('ctx, 'b) code

	val ( and* ) : ('ctx, 'a) code -> (_, 'b) code -> ('ctx, ('a * 'b)) code

	end
