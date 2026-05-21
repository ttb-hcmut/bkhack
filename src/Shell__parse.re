open Melange__containers.Fun
open Cprg
open Cprg.Syntax
open Shell__parse__lex

let end_of_seq = ignore @@ end_of_seq

let word = {
	let* w = word();
	switch (w) {
	| `raw(w)
	| `quoted(w, _) => return(w)
	}
}

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

let string =
	chain->Cprg.parse_string(~consume=`All)
