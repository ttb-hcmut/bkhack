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
and test = cwd => Path.(cwd / "test")

let fix = s => String.sub(s, 0, String.length(s) - 1)

let main = (~sw, dir, nukeDelim) => Promise.await_exn @@ {
	let open Promise__syntax({ let sw = sw });
	let- input1 = () => Path.load(Path.(dir / "input1.txt"))
	and- input2 = () => Path.load(Path.(dir / "input2.txt"))
	and- input3 = () => Path.load(Path.(dir / "split.txt"));
	let split = String.length(input3)>0? Diff.stringDisassembler(input3,[],String.length(input3)-1,"",[],false) |> List.map(a=>a.[0]):[]
	let res = Diff.compare(input1,input2,split,nukeDelim)|>List.map(((d,v))=>d++"|\t"++v)|>String.concat("\n");
	Path.save(~create=`Or_truncate(0o700), Path.(dir / "res.txt"), res);
	let res_expect = Path.load(Path.(dir / "res-expect.txt")) |> fix;
	assert(String.equal(res, res_expect))
}

let main = nukeDelim => Eio_main.run @@ env => {
	let domain_mgr = Stdenv.domain_mgr(env);
  let cwd = Stdenv.cwd(env);
	let fixtures = cwd |> test |> fixtures;
	Switch.run @@ sw => {
		let pool = Executor_pool.create(~sw, domain_mgr, ~domain_count=Domain.recommended_domain_count());
		fixtures |> Path.read_dir |> Fiber.List.iter(it => {
			let dir = suite(fixtures, it);
			if (!Path.is_directory(dir)) () else
			Executor_pool.submit_exn(pool, ~weight=0.5) @@ () =>
			Switch.run @@ sw =>
			main(~sw, dir, nukeDelim)
		});
	}
}

open Cmdliner
open Term.Syntax

let main =
	Cmd.v(Cmd.info("test/diff", ~doc="idk lol")) @@ {
		let+ nukeDelim = Arg.(required & opt(some(bool), None) &
			info(["nuke-delim"], ~doc="If enabled, SPLIT_DELIM will not be considered during diffing."));
		main(nukeDelim)
	}

let () =
	if (Sys.interactive^) () else
	exit @@ Cmd.eval @@ main
