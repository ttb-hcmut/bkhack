[@Bkhack.page "/projects"]
// open Melange__containers.Fun

module App = Keyboard.Make({
	// open React
	
	[@react.component]
	let make = () => {
		<>
		<header> <Component__header /> </header>
		<main></main>
		</>
	}
})

let () =
	( ReactDOM.querySelector("#root")->Option.get )
	->ReactDOM.Client.createRoot
	->ReactDOM.Client.render(<App />)
