module Modeline {
	open React

	[@react.component]
	let make = () => {
		<>
			<div className="logo">{"vi"->string}</div>
			<div className="mode insert"><label /></div>
		</>
	}
}

module Toolbar {
	[@react.component]
	let make = () => {
		<>
		</>
	}
}

module Sidebar {
	[@react.component]
	let make = () => {
		<> </>
	}
}

module Body {
	[@react.component]
	let make = () => {
		<> </>
	}
}
