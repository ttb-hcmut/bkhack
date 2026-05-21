open Cprg
open Cprg.Syntax

let ignore = x => x >>| _ => ();

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
	(take_while1(is_ws), take_while(is_ws))
}

let word = () => {
	let* first_char = peek_char;
	switch (first_char) {
	| None => fail("zero length, not a word")
	| Some(('a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_' | '$' | '-') as x) => {
		let* () = advance(1);
		let* str = take_while @@ fun
			| 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '-' | '_' => true | _ => false;
		return(`raw(String.init(1, _ => x) ++ str))
	}
	| Some(('\'' | '\"') as x) => {
		let* () = advance(1);
		let* str = take_while @@ fun | e when e === x => false | _ => true;
		let* _ = peek_char_fail;
		let* () = advance(1);
		return(`quoted(str, x))
	}
	| Some(_) => fail("invalid word")
	}
}

let pipe = char('|')

let (brak_l, brak_r) = (char('{'), char('}'))

let endl = char(';')

let _and_ = string("&&")

let end_of_seq = endl /* <|> (ignore @@ and_) */
