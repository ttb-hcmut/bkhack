type tree('t, 'ctx) = ..

module type S {
	type command('a) and conv('a, 'b)

	let info : (list(string), ~doc:string=?, conv('a, 'b)) => command('b)

	let unit : (unit => 'a) => conv(unit, 'a)

	let unit_of : command('acc) => ('acc => 'a) => conv(unit, 'a)

	let int : (int => 'a) => conv(int, 'a)

	let int_of : command('acc) => (int => 'acc => 'a) => conv(int, 'a)

	module Tree {
		module Match {
			let register_pat : command(tree('t, 'ctx)) => unit
		}
	}
}

module type Spec = (S) => {}

