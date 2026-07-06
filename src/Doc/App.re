/** adapted from [@storybook/react-webpack5 StorybookConfig] */
module type StorybookConfig {
	type t and framework
	let framework : (~name:string, ~options:(Js.t({ .. }))=?, unit) => framework
	let register : (~stories:(array(string))=?, ~addons:(array(string))=?, ~framework:(framework)=?, unit) => t
}

module Storybook : StorybookConfig {
	type t and framework;

	[@mel.obj]
	external framework :
	(
		~name:string,
		~options:(Js.t({ .. }))=?,
		unit
	) => framework;

	[@mel.obj]
	external register :
	(
		~stories:(array(string))=?,
		~addons:(array(string))=?,
		~framework:(framework)=?,
		unit
	) => t;
}

let default = {
	let stories = [|
		"../../../**/*.mdx",
		"**/*__stories.@(js|jsx|mjs|ts|tsx)" |]
	and addons = [|
		"@storybook/addon-webpack5-compiler-swc",
		"@storybook/addon-docs" |]
	and framework = Storybook.framework(
		~name="@storybook/react-webpack5", ());
	Storybook.register(~stories, ~addons, ~framework, ())
}
