[@Bkhack.page "/settings"]
// open Melange__containers.Fun

module App = Keyboard.Make({
	open React
	
	[@react.component]
	let make = () => {
		let form = useRef(Js.Nullable.null);
		let onSubmit = e => {
			Event.Synthetic.preventDefault(e);
			let o = form.current->Js.Nullable.toOption->Option.get->ReactDOM.domElementToObj;
			Dom.Storage.setItem("bkhack.language", o##"language"##value, Dom.Storage.localStorage);
		};
		let selected = {
			let language = Dom.Storage.getItem("bkhack.language", Dom.Storage.localStorage) |> Option.value(~default="en-US");
			e => (e === language ? Some(true) : None)
		};
		<>
		<header> <Component__header /> </header>
		<form onSubmit ref={form->ReactDOM.Ref.domRef} role="main">
			<header>
				<input type_="submit" className="save"></input>
			</header>
			<aside><ul></ul></aside>
			<main>
				<select id="language" className="language">
					<option selected=?(selected("vi-VN"))>{"vi-VN"->string}</option>
					<option selected=?(selected("en-US"))>{"en-US"->string}</option>
				</select>
			</main>
		</form>
		</>
	}
})

let () =
	( ReactDOM.querySelector("#root")->Option.get )
	->ReactDOM.Client.createRoot
	->ReactDOM.Client.render(<App />)
