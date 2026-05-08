[@react.component]
let make : (
	~memo_transition:( (string, list((string, string)), unit => unit) => unit )=?
) => React.element;
