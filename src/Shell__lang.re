/** [Shell] is subset of the Shell Command Language, as specified by POSIX.
     
    @see {https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html} */

type program =
	| Cons_cmd([`unfetched(list(string))], program)
	| Cons_subprogram(program, program)
	| Nil;

[@warning "-32"]
module type Sym = {
	type program and cmd

	let raw_cmd : list(string) => cmd

	let sub : program => cmd

	let cons : cmd => program => program

	let ( || ) : cmd => program => program

	let nil : program
};

module Test(S : Sym) = {
	open S
	
	let feed = raw_cmd(["feed"])

	let split = amount => raw_cmd(["split", amount |> string_of_int])

	let filter = raw_cmd(["filter"])

	let _ =
		feed || sub(split(10) || filter || nil) || filter || nil
};
