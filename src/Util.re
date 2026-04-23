let parseQueryParams = (search: string) => {
	Js.String.split(~sep="&", search)
	|> Js.Array.reduce(~init = [], ~f = (acc, pair) => {
		let parts = Js.String.split(~sep="=", pair);
		if (Js.Array.length(parts) == 2) {
			let key = Js.Array.unsafe_get(parts, 0) |> Js.Global.decodeURIComponent;
			let value = Js.Array.unsafe_get(parts, 1) |> Js.Global.decodeURIComponent;
			List.cons((key, value), acc)
		} else { acc }
	})
	|> Js.Dict.fromList
};

