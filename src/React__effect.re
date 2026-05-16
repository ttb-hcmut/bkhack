let async = f => () => {
	ignore(Fetch__syntax.({
		let* () = f ()
		return(())
	}));
	None
};

let useAsync0 = f => {
	let (error, err) = React.useState(() => None);
	React.useEffect0(() => {
		ignore(Fetch__syntax.({
			f() >!= (e => { err(_ => Some(e)); return() }) >>= (() => return());
		}));
		None
	});
	React.useEffect1(() => {
		error |> Option.iter(error => error->Js.Exn.anyToExnInternal->raise);
		None
	}, [|error|])
}

let useAsync1 = (f, deps) => {
	let (error, err) = React.useState(() => None);
	React.useEffect1(() => {
		ignore(Fetch__syntax.({
			f() >!= (e => { err(_ => Some(e)); return() }) >>= (() => return());
		}));
		None
	}, deps);
	React.useEffect1(() => {
		error |> Option.iter(error => error->Js.Exn.anyToExnInternal->raise);
		None
	}, [|error|])
}
