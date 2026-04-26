module type Data' = {
	let q : string;
};

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

module Fetch = Bkhack__fetch;

let all = (type t, module Data : Data with type t = t, module Env : Env) => Fetch.Syntax.({
	let open Fetch;
	let* resp = fetchWithInit(Env.backend ++ "/api/test/raw?query=" ++ Data.q,
		RequestInit.make(~method_=Post, ()));
	let* data = Fetch.Response.json(resp);
	return @@ Data.json @@ data
})
