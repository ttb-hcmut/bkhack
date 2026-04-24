module type Data = {
	let q : string;
};

module type Env = {
	let backend : string;
};

let all = (module Data : Data, module Env : Env) => Fetch.({
	fetchWithInit(Env.backend ++ "/api/test/raw?query=" ++ Data.q,
		RequestInit.make(~method_=Post, ()))
})
