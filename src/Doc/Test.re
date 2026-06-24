let%comptime file = Containers.({
	open Fun;
	let blank' = Re.(alt([char(' '), char('\t')]));
	let x = IO.with_in("../../../default/src/Static/styles/variables.css", IO.read_all);
	let get_regions = {
		Re.all(Re.compile @@ Re.(seq @@ [str(":root"), blank' |> rep, char('{'), group(any |> rep |> shortest), char('}') ]))
		%> List.map(g => Re.Group.get(g, 1))
	}
	let get_variables = {
		Re.all(Re.compile @@ Re.(seq @@ [str("--"), str("ctp"), char('-'), group(alt([alnum, char('_'), char('-')]) |> rep1 |> shortest), blank' |> rep, char(':'), blank' |> rep, group(seq @@ [char('#'), alnum |> rep1]), blank' |> rep, char(';')]))
		%> List.map(g => (Re.Group.get(g, 1), Re.Group.get(g, 2)))
	}
	let x : string = {
		x |> get_regions |> List.map(y => {
			y |> get_variables |> List.map(((x, y)) => x++"="++"'"++y++"'") |> String.concat("&")
		})
		|> String.concat("\n")
	};
	Printf.printf("%%BOC%%\"%s\"%%EOC%%", x);
	()
});

let strip_quote = Melange__re.({
	let f = g => g->Re.Group.get(1);
	Re.replace(~all=true, ~f) @@ Re.compile @@ Re.(seq([char('\''), group(any |> rep1), char('\'')]))
});

let load = file => {
	[@warning "-8"]
	let [light, dark] = String.split_on_char('\n', file);
	(light, dark)
}

let colors = str => String.split_on_char('&', str) |> List.map(s => {
	[@warning "-8"] let [name, value] = String.split_on_char('=', s);
	(name, value |> strip_quote)
})

let cells = ls =>
	ls |> List.map( ((name, value)) => {
		let style = ReactDOM.Style.make(
			~backgroundColor=value,
			~width="2rem", ~height="2rem", ());
		<li style>
			{name->React.string}
		</li>
	}) |> Array.of_list |> React.array;

[@react.component]
let make = (~alt) => {
	let (light, dark) = load(file);
	let style = ReactDOM.Style.make(
		~display="flex", ~flexWrap="wrap", ());
	<div style role="display">{alt ? dark->colors->cells : light->colors->cells}</div>
}
