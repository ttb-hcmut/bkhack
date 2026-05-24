let do_ = (memo, task) => {
	let open Melange__iter;
	let acc = Dom.Storage.getItem("bkhack.cmd-history", Dom.Storage.localStorage) |> Option.map(String.split_on_char(',')) |> Option.value(~default=[]);
	let acc = acc @ [memo];
	let acc = Iter.of_list(acc) |> Iter.cons(memo) |> Iter.rev |> Iter.mapi((i, x) => (i, x)) |> Iter.take_while(((i, _)) => i < 16) |> Iter.rev |> Iter.map(((_, x)) => x) |> Iter.to_list;
	Dom.Storage.setItem("bkhack.cmd-history", String.concat(",", acc), Dom.Storage.localStorage);
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
