[@Bkhack.page "/about"]

module About {
	let khang = "Le Cong Minh Khang"
	let tuong = "Ho Gia Tuong"
	let bao = "Le Nguyen Gia Bao"
	let bao' = "Kinten Le"
	let tung = "Vu Hoang Tung"
	let credits = [|
		("User interface designer", tuong),
		("Artist", khang),
		("Infrastructure engineer", bao),
		// rest
		("Emotional support buddy", tung),
	|]

	open React

	[@react.component]
	let make = () => {
		let li = fun | (role, name) => {
			<tr key=name>
				<td>{role->string}</td>
				<td>{name->string}</td>
			</tr>
		};
		<table>
		<tbody>
		{credits |> Array.map(li) |> React.array}
		</tbody>
		</table>
	}
}

module ReactDOM0 {
	let querySelector = x =>
		switch (ReactDOM.querySelector(x)) {
		| Some(x) => x
		| None =>
			Js.Console.error("khong tim thay element #root");
			failwith("lol")
		}
}

let () = {
	let element = ReactDOM0.querySelector("#root");
	let root = ReactDOM.Client.createRoot(element);
	ReactDOM.Client.render(root, <About />)
}
