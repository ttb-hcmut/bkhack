let args_replace = {
	let pat = Re.compile @@ Re.(char('?'));
	with_ => {
		let f = _ => with_;
		Re.replace(~all=true, ~f, pat)
	}
}

let selector_replace = {
	let pat = Re.compile @@ Re.(char('&'));
	with_ => {
		let f = _ => with_;
		Re.replace(~all=true, ~f, pat)
	}
}

let sorry = k => {
	try (k()) { | _ => () }
}

let format1 = (~className, str, arg1) => {
	let str = Kernel.undo_relative_indentation(~min_padding=Kernel.min_padding(str), str);
	let str = str |> selector_replace("."++className);
	let content = str |> args_replace("\""++arg1++"\"");
	sorry @@ () => {
		Containers.IO.File.write_exn(Sys.getenv("TEST")++"/generative/"++className++".css", content)
	};
	className
}
