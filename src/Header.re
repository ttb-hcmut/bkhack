let string = React.string;

[@react.component]
let make = () => {
	<>
		<a className="logo" href="/">
			<img src="/assets/logo.svg" />
			<div className="title">{string("BKHack")}</div>
		</a>
		<input />
	</>
}
