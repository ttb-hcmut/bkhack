open Command__sym
open Command__common

let example = [["feed"], ["sort"], ["split", "-c", "0"]] |> List.rev

type command('t) = list(list(string)) => cmd('t)

and cmd('t) = {
	command_t: unit => 't,
	command_info: command_info
}

and command_info = {
	command_info_mold: list(string)
}

and conv('a, 'b) = list(list(string)) => conv'('a, 'b)

and conv'('a, 'b) =
	| Conv_unit({ conv_f : unit => 'b })
	| Conv_int({ conv_f : int => 'b })

exception Not_matched

module A {
	type nonrec command('t) = command('t) and conv('a, 'b) = conv('a, 'b)

	let info = (type a, type b, spec, conv: conv(a, b)): command(b) =>
		argss => {
			let args = try (List.hd(argss)) { | Failure(_) => raise(Not_matched) };
			let assert_ = () => {
				assert(spec |> List.mapi((i, x) => (i, x)) |> List.fold_left((acc, (i, x)) => {
					let y = try (List.nth(args, i)) { | Failure(_) | Invalid_argument(_) => raise(Not_matched) };
					acc && String.equal(y, x)
				}, true))
			};
			switch (conv(argss)) {
			| Conv_unit({ conv_f }) =>
				assert_();
				{ command_t: conv_f, command_info: { command_info_mold: args }  }
			| Conv_int({ conv_f }) =>
				assert_();
				let i = try (int_of_string @@ List.nth(args, List.length(args) - 1)) { | Failure(_) | Invalid_argument(_) => raise(Not_matched) };
				let command_t = () => conv_f(i);
				{ command_t, command_info: { command_info_mold: args }  }
			}
		}

	let unit = f: conv(unit, 'a) => _argss => Conv_unit({ conv_f : f })

	let unit_of = (prev_cmd: command('acc), f: 'acc => 'a): conv(unit, 'a) => argss => {
		let prev_cmd = prev_cmd(List.tl(argss));
		let conv_f = () => f(prev_cmd.command_t());
		Conv_unit({ conv_f: conv_f })
	}

	let int = f: conv(int, 'a) => _argss => Conv_int({ conv_f : f })

	let int_of = (prev_cmd: command('acc), f: int => 'acc => 'a): conv(int, 'a) => argss => {
		let prev_cmd = prev_cmd(List.tl(argss));
		let conv_f = i => f(i, prev_cmd.command_t());
		Conv_int({ conv_f: conv_f })
	}

	module Tree {
		module Match {
			let register_pat = (type t, type ctx, c: command(tree(t, ctx))) => try({
				let c = c(example);
				let parse_feed = (type a, type b, c: feed(a, b)) => switch (c) {
					| Feed_ls => Js.Console.log(Printf.sprintf("is feed\n"))
					| Split_count(_, count) => Js.Console.log(Printf.sprintf("is split count (%d)", count))
					| Sort(_) => Js.Console.log(Printf.sprintf("is sort"))
				}
				let u = c.command_t()
				switch (u) {
				| Tree__feed(c) => parse_feed(c)
				| _ => raise(Not_found)
				}
			}) { | Not_matched | Assert_failure(_) => () }
		}
	}
}

let test () = {
	all |> List.iter((module Make : Spec) => {
		let open Make(A);
		()
	})
}
