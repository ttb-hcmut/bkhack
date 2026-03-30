let parseQueryParams = (search: string) => {
	let params = Js.Dict.empty();
	Js.String.split(~sep="&", search)
	|> Js.Array.forEach(~f = pair => {
		let parts = Js.String.split(~sep="=", pair);
		if (Js.Array.length(parts) == 2) {
			let key = Js.Array.unsafe_get(parts, 0) |> Js.Global.decodeURIComponent;
			let value = Js.Array.unsafe_get(parts, 1) |> Js.Global.decodeURIComponent;
			Js.Dict.set(params, key, value);
		}
	});
	params
};
