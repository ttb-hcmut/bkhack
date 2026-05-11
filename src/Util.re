let parseQueryParams = (search: string) => {
	Js.String.split(~sep="&", search)
	|> Js.Array.reduce(~init = [], ~f = (acc, pair) => {
		let parts = Js.String.split(~sep="=", pair);
		if (Js.Array.length(parts) == 2) {
			let key = Js.Array.unsafe_get(parts, 0)  ;
			let value = Js.Array.unsafe_get(parts, 1);
			List.cons((key, value), acc)
		} else { acc }
	})
	|> Js.Dict.fromList
};

let parseQueryParams' = (search: string) => {
	Js.String.split(~sep="&", search)
	|> Js.Array.reduce(~init = [], ~f = (acc, pair) => {
		let parts = Js.String.split(~sep="=", pair);
		if (Js.Array.length(parts) == 2) {
			let key = Js.Array.unsafe_get(parts, 0)  ;
			let value = Js.Array.unsafe_get(parts, 1);
			List.cons((key, value), acc)
		} else { acc }
	})
};

let stringQueryParams' = dict => {
	dict |> List.map( ((k, v)) => k++"="++v ) |> String.concat("&")
}

module List = {
	let replace_assoc' = (k, v, dict) =>
		switch (List.assoc_opt(k, dict)) {
			| Some(u) when (v == u) => dict
			| Some(_) => dict |> List.remove_assoc(k) |> xs => xs @ [(k, v)]
			| None => dict @ [(k, v)]
		}
}
