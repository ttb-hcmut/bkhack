module P {
  include Eio.Path;
};

module Output {
  let src = x =>
    "./_build/default/src/output/node_modules/bkhack/" ++ x ++ ".js";

  let src' = (~target, x) =>
    Eio.Path.native_exn(target) ++ "/node_modules/bkhack/" ++ x ++ ".js";
};

let fix_base_path = {
  let f = gr => Re.Group.get(gr, 1);
  Re.replace(
    ~all=false,
    ~f,
    Re.(
      compile @@ seq([str(Sys.getcwd()), char('/'), group(any |> rep1)])
    ),
  );
};

module Path {
  open Eio;

  let physlink = (~force=false, ~sw, process_mgr, ~link_to, file) =>
    Fiber.fork(~sw) @@
    (
      () =>
        Process.run(
          process_mgr,
          ["ln"] @ (force ? ["-f"] : []) @ [Path.native_exn(link_to), Path.native_exn(file)]
        )
    );

  let symlink' = (~sw, ~procm, ~link_to, file) =>
    Fiber.fork(~sw) @@
    (
      () => {
        let link_to = P.native_exn(link_to);
				Process.run(procm, ["ln", "--symbolic", link_to, Path.native_exn(file)])
      }
    );

  let symlink = (~sw, ~link_to, file) =>
    Fiber.fork(~sw) @@
    (
      () => {
        let link_to = {
          let x = fix_base_path @@ P.native_exn(link_to);
          Sys.getcwd() ++ "/" ++ x;
        };
        Path.symlink(~link_to, file);
      }
    );

  let mkdir = (~sw, ~perm=0o700, dirname, filename, f) =>
    Fiber.fork(~sw) @@
    (
      () => {
        let newpath = Path.(dirname / filename);
        Path.mkdir(~perm, newpath);
        Switch.run @@ (sw => f(sw, newpath));
      }
    );

  let copy_dir = (~sw, ~procm, from_, to_) =>
    Fiber.fork(~sw) @@
    (
      () =>
        Process.run(
          procm,
          ["cp", "-r", Path.native_exn(from_), Path.native_exn(to_)],
        )
    );

  exception Directory_doesnt_exist(string);

  let getdir = (dirname, filename, f) => {
    let newpath = Path.(dirname / filename);
    if ((!) @@ Path.is_directory(newpath)) {
      raise @@ Directory_doesnt_exist(Path.native_exn(newpath));
    };
    f(newpath);
  };
};

module Pnpm { module Process {
  let run = (process_mgr, ~stdout=?, ~stdin=?, ~stderr=?, cmd) =>
    Eio.Process.run(process_mgr, ~stdout?, ~stdin?, ~stderr?) @@
    ["pnpm", "exec", ...cmd];
}};

let n = ref(0);

let idgen' = clock => {
  let a = Eio.Time.now(clock) |> Float.to_int |> Int.to_string
  and b = {
    let x = n^ |> Int.to_string;
    n := n^ + 1;
    x;
  };
  a ++ "-" ++ b;
};

let idgen = clock => Eio.Time.now(clock) |> Float.to_int |> Int.to_string;

open Eio;

let is_page =
  Re.exec_opt(
    Re.(
      compile @@
      seq([
        str("Page"),
        str("__"),
        group(any |> rep1 |> shortest),
        str(".re"),
      ])
    ),
  )
  %> Option.map(
       Re.(gr => (`fname(Group.get(gr, 0)), `id(Group.get(gr, 1)))),
     );

/** [is_page' src_dir filename] @deprecated */

let is_page' = src_dir =>
  is_page
  %> Option.map(((`fname(x), y)) =>
       (`fpath(P.(src_dir / x)), `fname(x), y)
     );

let webpack_template = (~optimization, v) => {
  let s =
    v
    |> List.map(((k, v)) => "\"" ++ k ++ "\":\"" ++ v ++ "\"")
    |> String.concat(",\n");
  let splitChunks =
    fun
    | `Production => {|
  output: {
    filename: 'misc/[name].js',
    path: path.resolve(__dirname, 'dist'),
  },
  optimization: {
    splitChunks: { chunks: 'all' }
  },
|}
    | `Development => {|
  output: {
    filename: 'misc/[name].js',
    path: path.resolve(__dirname, 'dist'),
  },
|};
  Printf.sprintf(
		{|
			const webpack = require("webpack")
			const path = require("path")

			module.exports = {
				entry: {
%s
				},
				%s
			}
		|},
    s,
    splitChunks(optimization),
  );
};

let compile_jsfile' = (~procm, ~clock, ~cwd, ~watch=false, ~optimization, out_dir, ~log_dir=?, entries) => {
  let opt_to_str = fun
    | `Production => "production"
    | `Development => "development";
  let mkdirs = x => {
    let exists_ok = true
    and perm = 0o700;
    Path.mkdirs(~exists_ok, ~perm, x);
  };
	let outfold = fun
		| `raw(out_dir) => Path.native_exn(out_dir)
		| `cwd(out_dir) => Sys.getcwd()++"/"++ Path.native_exn(out_dir);
	let outextract = fun
		| `raw(out_dir) | `cwd(out_dir) => out_dir
  let wrapdir = (~log_dir=?, clock, k) =>
    switch (log_dir) {
    | None => k(Pnpm.Process.run(~stdout=?None))
    | Some(log_dir) =>
      mkdirs(log_dir);
      Path.with_open_out(
        P.(log_dir / (idgen'(clock) ++ ".stdout")),
        ~create=`Exclusive(0o700),
      ) @@
      (stdout => k(Pnpm.Process.run(~stdout)));
    };
  mkdirs(outextract @@ out_dir);
  mkdirs(Path.(cwd / "_build_webpack"));
  wrapdir(~log_dir?, clock) @@
  (
    run => {
      Path.save(
        ~create=`Or_truncate(0o700),
        Path.(cwd / "_build_webpack" / "config.js"),
      ) @@
      webpack_template(~optimization) @@
      List.map(
        ((x, y)) => ("../"++x, Sys.getcwd() ++ "/" ++ Path.native_exn(y)),
        entries,
      );
      run(procm) @@
      ["webpack"]
      @ (
        if (watch) {
          ["watch"];
        } else {
          [];
        }
      )
      @ 
        [
          "--config", Sys.getcwd()++"/_build_webpack/config.js",
          "--mode", opt_to_str(optimization),
          "--output-path", outfold(out_dir),
        ];
    }
  );
};

[@alert naive("TODO(khang+kinten) bao plz grep from AST!")]
module File_grep {
	let attrib = (attrib_name, refile') => {
		let wrap_exn = f =>
			try(f()) {
			| [@warning "-52"] Failure("hd") => raise(Not_found)
			};
		let quoted = x => Re.(seq([char('"'), x, char('"')]));
		let matches =
			Re.all(
				Re.(
					compile @@
					seq([
						char('['),
						char('@'),
						attrib_name,
						blank |> rep,
						quoted(group(any |> rep1 |> shortest)),
						blank |> rep,
						char(']'),
					])
				),
			) @@
			Path.load(refile');
		let fst_match = wrap_exn @@ (() => List.hd(matches));
		"." ++ Re.Group.get(fst_match, 1);
	};
}

let output__sync = (~clock, jsfile') =>
  /* NOTE(kinten) the generation of [jsfile] is responsible by another process. it is expected to be "ready to use" when it finally exists as a file */
  while ((!) @@ Path.is_file(jsfile')) {
    Time.sleep(clock, 0.5);
  };

let run_liveserver = (~sw, ~procm, dist_dir) =>
  Fiber.fork(~sw) @@
  (
    () =>
      Pnpm.Process.run(
        procm,
        [
          "live-server",
          "--cors",
          "--no-browser",
          Path.native_exn(dist_dir),
          "8080",
        ],
      )
  );
