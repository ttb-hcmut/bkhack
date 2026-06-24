type meta and story('component) and test and user_event and canvas and expectation and player

module type component { [@react.component] let make : 'a. Js.t({ .. } as 'a) => React.element }

[@mel.get] external player_canvas : player => canvas = "canvas"
[@mel.get] external player_userevent : player => user_event = "userEvent"

[@mel.obj]
external story : (
	~args: Js.t({ .. } as 'component)=?,
	~play: (player => Js.promise(unit))=?,
	unit
) => story('component);

[@mel.obj]
external meta : (
	~component: Js.t({ .. } as 'a) => React.element,
	~title:string=?,
	unit
) => meta;

[@mel.send] external userevent_type_ : user_event => Dom.htmlElement => string => Js.promise(unit) = "type";
[@mel.send] external userevent_click : Dom.htmlElement => Js.promise(unit) = "click";

[@mel.send] external canvas_getbytestid : canvas => string => Dom.htmlElement = "getByTestId";
[@mel.send] external canvas_getbyrole : canvas => string => Dom.htmlElement = "getByRole";

[@mel.module] external test: test = "storybook/test"

[@mel.send] external test_expect : test => Dom.htmlElement => expectation = "expect";
[@mel.send] external test_tobeinthedocument : expectation => expectation = "toBeInTheDocument"

let test_finish : expectation => Js.promise(unit) = [%mel.raw {| async function(o) { await o; return; } |}]
