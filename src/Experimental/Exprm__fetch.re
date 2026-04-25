module type Data = {
	let q : string;
};

module type Env = {
	let backend : string;
};

module Fetch = Bkhack__fetch;

let all = (module Data : Data, module Env : Env) => Fetch.Syntax.({
	let open Fetch;
	let* resp = fetchWithInit(Env.backend ++ "/api/test/raw?query=" ++ Data.q,
		RequestInit.make(~method_=Post, ()));
	let* data = Fetch.Response.json(resp);
	return @@ data
})
