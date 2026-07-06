/** [Shell] is subset of the Shell Command Language, as specified by POSIX.
     
    @see <https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html> */

type cmd =
	[ `unfetched(list(string)) ]

type program =
	| Cons_cmd(cmd, program)
	| Cons_subprogram(program, program)
	| Nil;

module Program {
	let rec cmd__last_opt' = fun
		| Cons_cmd(cmd, Nil) => Some(cmd)
		| Cons_cmd(_, next) => cmd__last_opt'(next)
		| Cons_subprogram(Nil, Nil) => None
		| Cons_subprogram(next, Nil) => cmd__last_opt'(next)
		| Cons_subprogram(_, next) => cmd__last_opt'(next)
		| Nil => None

	let cmd__last_opt = cmd__last_opt'
}
