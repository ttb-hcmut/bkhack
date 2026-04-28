/** vendored */
module Fetch__syntax = {
	open Js.Promise

	let ( >>= ) = (x, f) => x |> then_(f)

	let ( >!= ) = (x, f) => x |> catch(f)

	let return  = resolve

	let ( let* ) = ( >>= )
};

module type Data' = {
	let q : string;
};

[@alert experimental("Automatic query data demarshalling is WIP, it is currently manual.")]
module type Serializable = {
	type t
	let json : Js.Json.t => t
};

module type Data = {
	type t;
	include Data';
	include Serializable with type t := t;
};

module type Env = {
	let backend : string;
};

let all = (type t, module Data : Data with type t = t, module Env : Env) => Fetch__syntax.({
	let open Fetch;
	let q = Data.q;
	Js.Console.log(q);
	let* resp = fetchWithInit(Env.backend ++ "/api/test/free?query=" ++ q,
		RequestInit.make(~method_=Post, ()));
	let* data = Fetch.Response.json(resp);
	Js.Console.log(data)
	return @@ Data.json @@ data
})
