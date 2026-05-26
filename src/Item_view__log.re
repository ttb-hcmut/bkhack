module Inspectview {
	[@react.component]
	let make = (~className=?) => {
    let cls = className |> Option.value(~default="");
		<>
		<header className=("only "++cls)></header>
		<main></main>
		</>
	}
}

module Listview {
	[@react.component]
	let make = (~className=?) => {
    let cls = className |> Option.value(~default="");
		<>
		<header className=("only "++cls++" inspect")></header>
		<main></main>
		</>
	}
}
