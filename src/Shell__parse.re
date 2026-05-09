open Melange__containers.Fun
open Cprg
open Cprg.Syntax

let ignore = x => x >>| _ => ();

let advance = () => {
	let ended = ref(false);
	ignore @@ take_while1(_ => switch (ended^) { | false => { ended := true; true } | true => false })
}

let string = s => String.to_seq(s) |> Seq.fold_left(
	(acc, it) =>
		lift2(
			(x, y) => { x ++ String.init(1, _ => y) },
			acc, char(it)
		),
		take_while(_ => false)
)

let (whitespace, whitespace0) = {
	let is_ws = fun | ' ' | '\t' | '\n' => true | _ => false;
	(ignore(take_while1(is_ws)), ignore(take_while(is_ws)))
}

let word = {
	let* x = peek_char;
	switch (x) {
	| None => fail("zero length, not a word")
	| Some(('a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_' | '$' | '-') as x) => {
		let* () = advance();
		let* str = take_while @@ fun
			| 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '-' | '_' => true | _ => false;
		return(String.init(1, _ => x) ++ str)
	}
	| Some(_) => fail("invalid word")
	}
}

let pipe = char('|')

let (brak_l, brak_r) = (char('{'), char('}'))

let endl = char(';')

let _and_ = string("&&")

let end_of_seq = (ignore @@ endl) /* <|> (ignore @@ and_) */

let command = fix @@ command =>
	(word <* whitespace, command) ||> lift2(List.cons)
	or (word >>| x => [x])

open Shell__lang

let chain : code(program) = fix @@ impl =>
	(end_of_input >>| _ => Nil)
	or ((brak_l *> whitespace0 *> impl <* whitespace0 <* end_of_seq <* whitespace0 <* brak_r) <* whitespace0 <* pipe, whitespace0 *> impl) ||> lift2((a, b) => Cons_subprogram(a, b))
	or ((command <* whitespace0 <* pipe), whitespace0 *> impl) ||> lift2((a, b) => Cons_cmd(`unfetched(a), b))
	or ((brak_l *> whitespace0 *> impl <* whitespace0 <* end_of_seq <* whitespace0 <* brak_r) >>| x => Cons_subprogram(x, Nil))
	or ((command) >>| x => Cons_cmd(`unfetched(x), Nil))

exception Parsing(string)

let test_parse =
	Cprg.parse_string(~consume=`All, chain) %> fun
		| Ok(it) => it
		| Error(msg) => raise(Parsing(msg))
