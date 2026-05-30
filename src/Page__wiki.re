[@Bkhack.page "/wiki"]

module App'{
	[@react.component]
	let make =()=> {
		<>
		<header> <Component__header /> </header>
		</>
	}
}

module App = App'

let () =
	ReactDOM.querySelector("#root")->Option.get
	->ReactDOM.Client.createRoot
	->ReactDOM.Client.render(<App />)
