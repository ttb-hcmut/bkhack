open Melange__containers.Fun

let task = {
	Js.Promise.catch(e => {
		Js.Console.error(e);
		Js.Promise.reject(e->Js.Exn.anyToExnInternal) })
	%> Js.Promise.then_(() => Js.Promise.resolve())
	%> ignore
}

module Result {
	include Result

	let lift = (a, b) => map(b, a)
}

module List {
	include List

	let last = x => x |> List.rev |> List.hd;

	let last_opt = it => try (Some(last(it))) { | _ => None }
}

