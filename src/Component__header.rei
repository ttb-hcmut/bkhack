[@react.component]
let make : (
  ~on_help: bool => unit,
	~memo_transition:( (string, list((string, string)), unit => unit) => unit )=?
) => React.element;
