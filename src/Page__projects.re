[@Bkhack.page "/projects"]
// open Melange__containers.Fun

module App = Keyboard.Make({
	open React
	
	[@react.component]
	let make = () => {
    let (_showHelp, setShowHelp) = useState(() => false);
    let on_help = x => setShowHelp(_ => x);
		<>
		<header> <Component__header on_help /> </header>
		<main></main>
		</>
	}
})

let () =
	( ReactDOM.querySelector("#root")->Option.get )
	->ReactDOM.Client.createRoot
	->ReactDOM.Client.render(<App />)
