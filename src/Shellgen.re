open Melange__containers.Fun

module Core = {
	type cmd =
		| Raw_cmd(list(string)) : cmd
		| Subsection(program) : cmd

	and program =
		| Cons(cmd, program)   : program
		| Nil : program
	
	and obs = React.element

	let raw_cmd = xs => Raw_cmd(xs)

	and sub = x => Subsection(x)

	and (cons, ( @| )) = {
		let f = (x, xs) => Cons(x, xs);
		(f, f)
	}

	and nil = Nil

	and observe : program => obs = {
		let rec of_prog = fun
			| Cons(cmd, Nil) => of_cmd(cmd)
			| Cons(cmd, prog) => of_cmd(cmd)++" | "++of_prog(prog)
			| Nil => ""
		and of_cmd = fun
			| Raw_cmd(xs) => String.concat(" ", xs)
			| Subsection(prog) => "{ "++of_prog(prog)++" ;}"
		and span = x => <span className="command">{x}</span>;
		span % React.string % of_prog
	}
}

module Common {
	include Core

	let feed = raw_cmd(["feed"])

	and split = (~count, ()) => raw_cmd(["split", "-c", string_of_int(count)])
}

include Common
