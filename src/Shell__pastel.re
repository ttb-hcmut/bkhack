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

let command = fix @@ command =>
	{ let* word = word; let* ws = whitespace; let* command = command;
		return([word, ws, ...command])
	}
	or { let* word = word; return([word]) }

open React

let char = { let string_of_char = String.make(1); React.string % string_of_char }

let chain_1 = impl => {
	let* brak_l = brak_l; let* ws0 = whitespace0; let* impl1 = impl; let* ws1 = whitespace0; let* end_of_seq = end_of_seq; let* ws2 = whitespace0; let* brak_r = brak_r; let* ws3 = whitespace0; let* pipe = pipe; let* ws4 = whitespace0; let* impl2 = impl;
	return (
	<>
	<span className="punctuation bracket sh">{brak_l->char}</span> {ws0->string}
		{impl1} {ws1->string} <span className="punctuation delimiter sh">{end_of_seq->char}</span> {ws2->string}
	<span className="punctuation bracket sh">{brak_r->char}</span> {ws3->string}
	<span className="operator sh">{pipe->char}</span> {ws4->string}
	{impl2}
	</>
	)
}

let chain_2 = impl => {
	let open Melange__iter;
	let* command = command; let* ws0 = whitespace0; let* pipe = pipe; let* ws1 = whitespace0; let* impl = impl;
	return (
	<>
	{command |> Iter.of_list |> Iter.mapi(fun
		| 0 => s => <span key=s className="function call sh">{s->string}</span>
		| _ => s => <span key=s className="variable parameter sh">{s->string}</span> ) |> Iter.to_array |> array}
	{ws0->string}
	<span className="operator sh">{pipe->char}</span> {ws1->string}
	{impl}
	</>
	)
}

let chain_3 = impl => {
	let* brak_l = brak_l; let* ws0 = whitespace0; let* impl = impl; let* ws1 = whitespace0; let* end_of_seq = end_of_seq; let* ws2 = whitespace0; let* brak_r = brak_r;
	return (
	<>
	<span className="punctuation bracket sh">{brak_l->char}</span> {ws0->string}
		{impl} {ws1->string} <span className="punctuation delimiter sh">{end_of_seq->char}</span> {ws2->string}
	<span className="punctuation bracket sh">{brak_r->char}</span>
	</>
	)
}

let chain_4 = {
	let open Melange__iter;
	let* command = command;
	return (
	<>
	{command |> Iter.of_list |> Iter.mapi(fun
		| 0 => s => <span key=s className="function call sh">{s->string}</span>
		| _ => s => <span key=s className="variable parameter sh">{s->string}</span> ) |> Iter.to_array |> array}
	</>
	)
}

let chain : code(React.element) = fix @@ impl =>
	(end_of_input >>| _ => <> </>)
	or chain_1(impl) or chain_2(impl) or chain_3(impl) or chain_4

exception Parsing(string)

let test_parse =
	Cprg.parse_string(~consume=`All, chain) %> fun
		| Ok(it) => it
		| Error(msg) => raise(Parsing(msg))
