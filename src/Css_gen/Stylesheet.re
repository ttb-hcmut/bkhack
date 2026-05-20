let args_replace = {
	let pat = Re.compile @@ Re.(char('?'));
	(s, with_) => {
		let f = _ => with_;
		Re.replace(~all=true, ~f, pat, s)
	}
}

let selector_replace = {
	let pat = Re.compile @@ Re.(char('&'));
	(s, with_) => {
		let f = _ => with_;
		Re.replace(~all=true, ~f, pat, s)
	}
}

let format1 = (~className, str, arg1) => {
	let str = selector_replace(str, "."++className);
	let content = args_replace(str, "\""++arg1++"\"");
	try (Containers.IO.File.write_exn(Sys.getenv("TEST")++"/generative/"++className++".css", content)) { | _ => () };
	className
}
