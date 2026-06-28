module Date {
	let now = () => 0.
}

let logMany = ss => {
	Printf.printf("%s", ss |> Array.to_list |> String.concat("\n"))
}

module Re {
	type t
}

module String {
	let match = (~regexp: Re.t, s: string) : option(array(option(string))) => {
		ignore(regexp); ignore(s); failwith("unimplemented")
	}
}
