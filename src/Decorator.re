open React

module type Component = {
	[@react.component] let make : unit => element
}

type component = (module Component)

module type Maker = (_ : Component) => Component

type maker = (module Maker)

module React {
	include React

	let use = ((module It : Component), (module Maker : Maker)) => {
		let it = (module Maker(It) : Component);
		it
	}
}
