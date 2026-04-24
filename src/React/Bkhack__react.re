include React;

module Fetch = Bkhack__fetch;

module Effect = {
	let async = f => () => {
		ignore(Fetch.Syntax.({
			let* () = f ()
			return(())
		}));
		None
	};
}
