open Melange__containers.Fun

let task = {
	Js.Promise.catch(e => {
		Js.Console.error(e);
		Js.Promise.reject(e->Js.Exn.anyToExnInternal) })
	%> Js.Promise.then_(() => Js.Promise.resolve())
	%> ignore
}
