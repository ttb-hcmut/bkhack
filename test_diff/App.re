open Eio

[@warning "-32-33"]
module Promise__syntax (U : { let sw: Switch.t }) {
	open U

	let bind = (rhs, k) => {
		Fiber.fork_promise(~sw) @@ () => {
			let x = rhs(); k(x)
		}
	}

	let ( let- ) = bind

	let product = (rhs1, rhs2) => {
		let (x1, r1) = Promise.create() and (x2, r2) = Promise.create();
		Fiber.both(() => Promise.resolve(r1, rhs1()), () => Promise.resolve(r2, rhs2()));
		() => {
			let x1' = Promise.await(x1) and x2' = Promise.await(x2);
			(x1', x2')
		}
	}

	let ( and- ) = product
}

[@warning "-32-33"]
module Promise__syntax' (U : { let sw: Switch.t }) {
	open U

	let bind = (rhs, k) => {
		let x = rhs(); k(x)
	}

	let ( let- ) = bind

	let product = (rhs1, rhs2) => {
		() => {
			let x1' = rhs1() and x2' = rhs2();
			(x1', x2')
		}
	}

	let ( and- ) = product
}

let suite = (fixtures, name) => Path.(fixtures / name)
and fixtures = test => Path.(test / "fixtures")
and test = cwd => Path.(cwd / "test_diff")

let pool = (domain_mgr, k) => Switch.run @@ sw => {
	let pool = Executor_pool.create(~sw, domain_mgr, ~domain_count=Domain.recommended_domain_count());
	let spawn = fn => Executor_pool.submit_exn(pool, ~weight=0.5, fn);
	k(spawn)
}

let fix = s => String.sub(s, 0, String.length(s) - 1)

let runtest = (~sw, ~clock, dir, nukeDelim) => Promise.await_exn @@ {
	let open Promise__syntax({ let sw = sw });
	let- input1 = () => Path.load(Path.(dir / "input1.txt"))
	and- input2 = () => Path.load(Path.(dir / "input2.txt"))
	and- input3 = () => Path.load(Path.(dir / "split.txt"));
	let split = String.length(input3)>0? Diff.stringDisassembler(input3,[],String.length(input3)-1,"",[],false) |> List.map(a=>a.[0]):[]
	let timestart = Eio.Time.now(clock);
	let (res, `tokens(tokens)) = Diff.compare'(input1,input2,split,nukeDelim,());
	let res = res |>List.map(((d,v))=>d++"|\t"++v)|>String.concat("\n");
	let timeend = Eio.Time.now(clock);
	let static_info = ((), `split(split |> List.map(c => String.make(1, c)) |> String.concat("")), `time(timeend -. timestart), `tokencount(Array.length(tokens)));
	Promise.await_exn @@ {
		let- () = () => Path.save(~create=`Or_truncate(0o700), Path.(dir / "res.txt"), res)
		and- res_expect = () => Path.load(Path.(dir / "res-expect.txt")) |> fix;
		assert(String.equal(res, res_expect));
		static_info
	}
}

let main = (~nukeDelim, ~outputFormat, env) => {
	let filter_directory = dir => Path.is_directory(dir) ? Some(dir) : None;
	let outputFormat = outputFormat(env)
	let domain_mgr = Stdenv.domain_mgr(env) and cwd = Stdenv.cwd(env) and clock = Stdenv.clock(env);
	let fixtures = cwd |> test |> fixtures;
	pool(domain_mgr) @@ parallel =>
	fixtures |> Path.read_dir |> Fiber.List.filter_map(it => {
		let dir = suite(fixtures, it);
		filter_directory(dir) |> Option.map @@ dir =>
		parallel @@ () =>
		Switch.run @@ sw =>
		try ({
			let ((), split, time, tokencount) = runtest(~sw, ~clock, dir, nukeDelim);
			(it, true, split, time, tokencount)
		}) {
			| Assert_failure(_) => failwith("test '"++it++"' did not pass")
		}
	}) |> outputFormat;
}

let dry = (_, _) => {
	()
}

let csv = (env, res) => {
	let cwd = Stdenv.cwd(env);
	let csv = res |> List.map( ((it, _, `split(split), `time(time), `tokencount(tokencount))) => [|it, (switch (split) { | " \n" => "SPACE" | "\n\n" => "NEWLINE" | _ => failwith("wtf") }), string_of_int(Float.to_int(time *. 1000.0))++"ms", string_of_int(tokencount)|]) |> Array.of_list |> Csv.of_array;
	Eio_unix.run_in_systhread(~label="csv_save") @@ () =>
	csv |> Csv.save(Path.((cwd |> test) / "res.csv") |> Path.native_exn)
}

open Cmdliner
open Term.Syntax

let main = Cmd.v(Cmd.info("test/diff", ~doc="idk lol")) @@ {
	let+ nukeDelim = Arg.(required & opt(some(bool), None) &
		info(["nuke-delim"], ~doc="If enabled, SPLIT_DELIM will not be considered during diffing."))
	and+ outputFormat = Arg.(required & opt(some(enum([("csv", csv),("dry", dry)])), None) &
		info(["fmt"], ~docv="OUTPUT_FORMAT", ~doc="Output format."));
	Eio_main.run @@ main(~nukeDelim, ~outputFormat)
}

let () =
	if (Sys.interactive^) () else
	exit @@ Cmd.eval @@ main
