/** [Shell] is subset of the Shell Command Language, as specified by POSIX.
     
    @see {https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html} */

type program =
	| Cons_cmd([`unfetched(list(string))], program)
	| Cons_subprogram(program, program)
	| Nil

let test_parse : string => result(program, string)
