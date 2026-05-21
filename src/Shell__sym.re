module type Sym = {
	type program and cmd and obs

	let raw_cmd : list(string) => cmd

	let sub : program => cmd

	let cons : cmd => program => program

	/** @canonical {cons} */
	let ( @| ) : cmd => program => program

	let nil : program

	let observe : program => obs
};

module type SymL {
	include Sym
	
	let feed : cmd

	module Split_by {
		let count : int => cmd
	}
}
