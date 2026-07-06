module type Sys = (module type of Sys)

module type IO = {
	let root_opt : (module Sys) => option(string)
	let capture : string => unit
}

module type Work = (IO) => {}

module type Empty = {}

module Begin (K : Work) {

	let get_in_build_sandbox_opt = {
		let pat = Re.compile @@ Re.(seq([any |> rep, str("_build"), str(Filename.dir_sep), str(".sandbox"), str(Filename.dir_sep), alnum |> rep1, str(Filename.dir_sep), group(any |> rep)]));
		let match_ = Re.exec_opt @@ pat;
		let map_compensate = g => "../../../"++Re.Group.get(g, 1)++"/";
		match_ %> Option.map(map_compensate)
	};

	let get_in_build_opt = {
		let pat = Re.compile @@ Re.(seq([any |> rep, str("_build"), str(Filename.dir_sep), group(any |> rep)]));
		let match_ = Re.exec_opt @@ pat;
		let map_compensate = g => Re.Group.get(g, 1);
		match_ %> Option.map(map_compensate)
	};

	module IO {
		let root_opt (module Sys : Sys) =
			get_in_build_sandbox_opt(Sys.getcwd())
			|> Option.fold(~none=get_in_build_opt(Sys.getcwd()), ~some=Option.some);

		let capture = s =>
			Printf.printf("%%BOC%%\"%s\"%%EOC%%", s)
	};

	{ let _ = (module K(IO) : Empty); () }
}
