open Eio
module Pnpm = Buildlib.Build.Pnpm
module P = Path
module B = Buildlib.Build

exception Missing_mapping_entry_for(string)

let attrib_name = Re.(
  alt([str("page"), str("Bkhack.page")]));

/** a [morphism] for JavaScript bundles */
let morphism_jspages = (~sw,~procm,~clock,~cwd, ~optimization, ~watch=?, ~target_dir, ~srcs, src_dir, ~log_dir=?, dist_dir) =>  {
	let jspages = () =>
		List.filter_map(B.is_page'(src_dir))
		@@ Path.read_dir(src_dir);
	let output_dirs = jspages => jspages |> Fiber.List.map(x' => {
		let (`fpath(refile'), `fname(refile), _) = x';
		let jsfile  = B.Output.src'(~target=target_dir) @@ Filename.chop_extension(refile);
		let jsfile' = P.(cwd / jsfile);
		let out_dir =
			try (B.file_grep_attrib(attrib_name, refile'))
			{ | Not_found => raise @@ Missing_mapping_entry_for(refile) };
		(out_dir++"/index", jsfile')
	});
	let output_dirs' = srcs => srcs |> List.map(s => {
		let name = Filename.basename(s)
		and jsfile = P.(cwd / s);
		("/"++name, jsfile)
	});
	Fiber.fork(~sw) @@ () =>
	(output_dirs(jspages()) @ output_dirs'(srcs)) |> B.compile_jsfile'(~procm,~clock,~cwd, ~watch?, ~optimization, dist_dir, ~log_dir?)
};

/** a [morphism] for lucide icons */
let morphism_lucide = (~sw,~procm, lucide_dir, dist_dir) => {
  let icons_dir = P.(lucide_dir / "icons");
  B.Path.copy_dir(~sw,~procm, icons_dir, P.(dist_dir / "icons"))
};

/** a [morphism] for linking static-content files from public dir
    (and other sources) to dist dir */
let morphism_static = (~sw,~procm,~cwd, items, dist_dir, ()) => {
  let iter = (f, ~ondir, rootdir: list(string)) => {
    ondir(String.concat("/", rootdir));
    Fiber.List.iter(it => {
			let parts = String.split_on_char('/', it);
			let hd = List.hd(parts) and it = List.tl(parts);
			let it' = rootdir @ it;
			let mkdir_target = Filename.dirname(String.concat("/", it'));
			// traceln("mkdir_target:%s", mkdir_target);
			Path.mkdirs(~exists_ok=true, ~perm=0o700, P.(dist_dir / mkdir_target));
			f(hd, it')
		}, items)
	};
  let iter_ondir = dirpath_at_public => {
    let dirpath_at_dist = P.(dist_dir / dirpath_at_public);
    Path.mkdirs(~exists_ok=true, ~perm=0o700, dirpath_at_dist)
	};
  iter(~ondir=iter_ondir, (hd, fpath_at_public) => {
		let path_it = String.concat("/", fpath_at_public);
		B.Path.physlink(~sw, procm,
			P.(dist_dir / path_it),
			~link_to=P.(cwd / hd / path_it))
	}, [])
}

let morphism_generative = (~sw,~procm, generative_dir, dist_dir) => {
  let at_dir = (dir, k) => { Path.mkdirs(~exists_ok=true, ~perm=0o700, dir); k(); }
  let create_index = (name, candidates) => {
    let content = candidates |> List.map(Printf.sprintf({|@import "/%s";|})) |> String.concat("\n");
    Path.save(~create=`Exclusive(0o700), P.(dist_dir / name), content)
	};
  at_dir(generative_dir) @@ () => {
		let candidates = Path.read_dir(generative_dir) |> List.filter(x => Filename.extension(x) == ".css");
		at_dir(dist_dir) @@ () => {
			create_index("generative.css", candidates);
			candidates |> Fiber.List.iter @@ path_it =>
			B.Path.physlink(~sw, procm,
				P.(dist_dir / path_it),
				~link_to=P.(generative_dir / path_it))
		}
	}
};

/** [Serve] will run a series of [morphism]s (some are persistent
    while some are not) on the repository to finally arrive at an
    output at [dist_dir].

    TODO(kinten) provides guide

    @raise Missing_mapping_entry_for(pagefile) when a Reason page
    file did not specify a required `[@Bkhack.page s]` attribute.
    Refer to the guide for more details. */
let main__ = (~watch, ~dist_dir, ~src_dir, ~static_items, ~generative_dir, ~log_dir, ~lucide_dir, ~verbose, ~optimization, ~target_dir, ~srcs, ()) => Eio_main.run @@ env => {
  let (procm, clock, cwd, fs) =
    (Stdenv.process_mgr(env), Stdenv.clock(env), Stdenv.cwd(env), Stdenv.fs(env));
  let (generative_dir, dist_dir, log_dir, src_dir, lucide_dir, target_dir) =
    (generative_dir(fs), dist_dir(cwd), (!verbose ? Some (log_dir(cwd)) : None), src_dir(cwd), lucide_dir(fs), target_dir(cwd));
  Switch.run @@ sw => {
		morphism_jspages(~sw,~procm,~clock,~cwd, ~optimization, ~watch, ~target_dir, ~srcs, src_dir, ~log_dir?, dist_dir);
		morphism_static(~sw,~procm,~cwd, static_items, dist_dir, ());
		morphism_generative(~sw,~procm, generative_dir, dist_dir);
		morphism_lucide(~sw,~procm, lucide_dir, dist_dir)
	}
}

open Cmdliner
open Term.Syntax

type args = {
	args_static: list(string),
	args_gen: list(string),
	args_srcs: list(string),
	args_other: list(string)
}

let main__ = () => Cmd.v(Cmd.info("webpackgen", ~doc="")) @@ {
  let log_dir = cwd => P.(cwd / "log");
  let+ dist_dir = Arg.(required & opt((some(string)), None) &
    info(["output", "o"], ~doc=" Output directory, containing deployable web bundle artifact. "))
    |> Term.map(Path.((it, cwd) => cwd / it))
  and+ src_dir = Arg.(required & opt((some(string)), None) &
    info(["src_dir"], ~doc=" Source directory. "))
    |> Term.map(Path.((it, cwd) => cwd / it))
  and+ target_dir = Arg.(required & opt((some(string)), None) &
    info(["target"], ~doc=" Target directory. "))
    |> Term.map(Path.((it, cwd) => cwd / it))
  and+ generative_dir = Arg.(required & opt((some(string)), None) &
    info(["generative_dir"], ~doc=" Generative asset directory. "))
    |> Term.map(Path.((it, fs) => fs / it))
  and+ lucide_dir = Arg.(required & opt((some(string)), None) &
    info(["lucide_dir"], ~doc=" (DEPRECATED) Lucide icon directory. "))
    |> Term.map(Path.((it, fs) => fs / it))
  and+ verbose = Arg.(required & opt((some(bool)), None) &
    info(["verbose"], ~docv="VERBOSE"))
  and+ optimization = Arg.(required & opt((some @@ enum @@ [("dev", `Development), ("release", `Production)]), None) &
    info(["optimization", "O"], ~docv="OPTIMIZATION"))
	and+ lol = Arg.(value & pos_all(string, []) & info([], ~docv="haha")) |> Term.map(xs => {
		xs |> List.fold_left(((mode, acc), it) => {
			switch (it, mode) {
			| (":static", _) => (`static, acc)
			| (":gen", _) => (`gen, acc)
			| (":srcs", _) => (`srcs, acc)
			| (it, `static as mode) => (mode, { ...acc, args_static: [it, ...acc.args_static] })
			| (it, `gen as mode) => (mode, { ...acc, args_gen: [it, ...acc.args_gen] })
			| (it, `srcs as mode) => (mode, { ...acc, args_srcs: [it, ...acc.args_srcs] })
			| (it, `other as mode) => (mode, { ...acc, args_other: [it, ...acc.args_other] })
			}
		}, (`other, { args_static: [], args_gen: [], args_srcs: [], args_other: [] })) |> (((_, b)) => b)
	});
	let srcs = []; // lol.args_srcs;
  main__(~watch=false, ~dist_dir, ~src_dir, ~static_items=lol.args_static, ~generative_dir, ~log_dir, ~lucide_dir, ~verbose, ~optimization, ~target_dir, ~srcs, ())
};

/** autorun except in toplevel / interactive mode */
let () =
  if (Sys.interactive^) () else
  exit @@ Cmd.eval @@ main__()
