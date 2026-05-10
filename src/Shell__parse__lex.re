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
	(take_while1(is_ws), take_while(is_ws))
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

let end_of_seq = endl /* <|> (ignore @@ and_) */
