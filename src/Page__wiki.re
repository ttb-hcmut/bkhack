[@Bkhack.page "/wiki"]

module App'{
  open React

	[@react.component]
	let make =()=> {
    let (_showHelp, setShowHelp) = useState(() => false);
    let on_help = x => setShowHelp(_ => x);
		<>
		<header> <Component__header on_help /> </header>
		</>
	}
}

module App = App'

let () =
	ReactDOM.querySelector("#root")->Option.get
	->ReactDOM.Client.createRoot
	->ReactDOM.Client.render(<App />)
