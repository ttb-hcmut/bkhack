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

let _sorry = k => {
	try (k()) { | _ => () }
}

let is_in_build = {
	let pat = Re.compile @@ Re.(seq([any |> rep, str("_build"), any |> rep]));
	Re.execp @@ pat
}

let format1 = (~className, str, arg1) => {
	let str = Kernel.undo_relative_indentation(~min_padding=Kernel.min_padding(str), str);
	let str = str |> selector_replace("."++className);
	let content = str |> args_replace("\""++arg1++"\"");
	if (!(is_in_build @@ Sys.getcwd())) () else {
		try ( Sys.mkdir("/tmp/generative", 0o700) ) { | _ => () }
		Containers.IO.File.write_exn("/tmp/generative/"++className++".css", content);
	};
	className
}
