let async = f => () => {
	ignore(Fetch__syntax.({
		let* () = f ()
		return(())
	}));
	None
};
