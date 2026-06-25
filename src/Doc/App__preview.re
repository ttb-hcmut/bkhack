/** adapted from @storybook/react-webpack5 Preview */
module Preview {
	type t = {
		[@mel.as "parameters"] parameters: parameters
	}

	and parameters = {
		[@mel.as "controls"] parameters_controls: parameters_controls
	}

	and parameters_controls = {
		[@mel.as "matchers"] parameters_controls_matcher: parameters_controls_matcher
	}

	and parameters_controls_matcher = {
		[@mel.as "color"] parameters_controls_matcher_color: Js.Re.t,
		[@mel.as "date"] parameters_controls_matcher_date: Js.Re.t
	}
}

let default = Preview.{
	parameters: {
		parameters_controls: {
			parameters_controls_matcher: {
				parameters_controls_matcher_color: Js.Re.fromString("/Date$/i"),
				parameters_controls_matcher_date: Js.Re.fromString("/(background|color)$/i"),
			}
		}
	}
}
