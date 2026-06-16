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

module type IO = {
	include (module type of Containers.IO.File)
	include (module type of Sys)
	let mkdir' : (string, int) => unit
}

module type Work = (IO) => {}

module type Empty = {}

module Gen (K : Work) {
	module IO : IO {
		include Containers.IO.File
		let write_exn = path => write_exn("/tmp/generative/"++path)
		include Sys
		let mkdir' = path => mkdir("/tmp/generative"++path)
	}

	let is_in_build = {
		let pat = Re.compile @@ Re.(seq([any |> rep, str("_build"), any |> rep]));
		Re.execp @@ pat
	}

	if (!(is_in_build @@ Sys.getcwd())) () else
	{ let _ = (module K(IO) : Empty); () }
}

let format1 = (~className, str, arg1) => {
	let content = str
		|> Kernel.undo_relative_indentation(~min_padding=Kernel.min_padding(str))
		|> selector_replace("."++className)
	  |> args_replace("\""++arg1++"\"");
	let open Gen((IO : IO) => {
		try ( IO.mkdir'("", 0o700) ) { | Sys_error(_) => () }
		IO.write_exn(className++".css", content);
	});
	className
}
