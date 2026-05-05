let do_ = (memo, task) => {
	let acc = Dom.Storage.getItem("bkhack.cmd-history", Dom.Storage.localStorage) |> Option.map(String.split_on_char(',')) |> Option.value(~default=[]);
	Dom.Storage.setItem("bkhack.cmd-history", String.concat(",", acc @ [memo]), Dom.Storage.localStorage);
	task()
}

let index_init = () => Dom.Storage.getItem("bkhack.cmd-history", Dom.Storage.localStorage) |> Option.map(String.split_on_char(',')) |> Option.value(~default=[]) |> List.length

let on_scroll = (historyIndex, k) => {
	let a = x => List.nth_opt(x, historyIndex);
	let u =
		Dom.Storage.getItem("bkhack.cmd-history", Dom.Storage.localStorage) |> Option.map(String.split_on_char(',')) |> Option.value(~default=[])
		|> a;
	k(u)
}
