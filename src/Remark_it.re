open Js__markdown
module M = Melange__cmarkit.Cmarkit

type renderer_string = unit => renderer_string'

and renderer_string' = R_string(Unified.t)

type renderer_element = unit => renderer_element'

and renderer_element' = R_element(Unified.t)

type doc = (M.Block.t, string)

module Cmarkit_html {
	let renderer = (~safe: bool, ()) : renderer_string => {
		ignore(safe);
	  () => R_string({
			Unified.(make()
				->use(Remark.parse)
				->use(Remark.gfm)
				->use(Remark.rehype)
				->use(Rehype.sanitize)
				->use(Rehype.stringify))
		})
	}

	let renderer' = (~safe: bool, ()) : renderer_element => {
		ignore(safe);
		() => R_element({
			Unified.(make()
				->use(Remark.parse)
				->use(Remark.gfm)
				->use(Remark.rehype)
				->use(Rehype.sanitize)
				->use2(Rehype.react, React.JsxRuntime.production))
		})
	}
}

module Cmarkit_renderer {
	let doc_to_string = (renderer : renderer_string, (_skel, s) : doc) => {
		let R_string(x) = renderer();
		x->Unified.process'(s)->string
	}

	let doc_to_string' = (renderer : renderer_element, (_skel, s) : doc) => {
		let R_element(x) = renderer();
		let u = x->Unified.process'(s)->React.UFile.result;
		Js.Console.log(u);
		u
	}
}

module Cmarkit {
	module Link_definition {
		include M.Link_definition

		let parse = s => {
			M.Link_definition.make(~dest=(s, M.Meta.none), ())
		}
	}

	module InlineCore {
		include M.Inline

		let rec parse = (skel, k) => {
			switch skel##"type" {
			| "emphasis" =>
				let content = M.Inline.Emphasis.make(~delim='*', skel->parse_inlines(k))
				and meta = M.Meta.none;
				M.Inline.Inline_Emphasis((content, meta))
			| "strong" =>
				let content = M.Inline.Emphasis.make(~delim='_', skel->parse_inlines(k))
				and meta = M.Meta.none;
				M.Inline.Strong_emphasis((content, meta))
			| "inlineCode" =>
				let content = M.Inline.Code_span.of_string(skel##"value");
				M.Inline.Inline_Code_span((content, M.Meta.none))
			| "link" =>
				let text = skel->parse_inlines(k)
				and reference = `Inline((Link_definition.parse(skel##"url"), M.Meta.none));
				M.Inline.Inline_Link((M.Inline.Link.make(text, reference), M.Meta.none))
			| "text" => M.Inline.Text((skel##"value", M.Meta.none))
			| s => failwith("unknown remark inline of type '"++s++"'")
			}
		}

		and parse_inlines = (skel, k) => {
			let children = (skel##"children") |> Array.map(k) |> Array.to_list
			and meta = M.Meta.none;
			M.Inline.Inlines((children, meta))
		}
	}

	module InlineExt {
		include InlineCore

		let strikethrough =v=> 
			String.(v->length) >= 2 && {
				let ch1 = String.(v->get(0)) and ch2 = String.(v->get(v->length - 1));
				switch (ch1, ch2) { | ('~', '~') => true | (_, _) => false }
			};

		let parse = (skel, k) => {
			let v = skel##value;
			switch skel##"type" {
			| "text" when strikethrough(v) =>
				let a = String.(v->sub( 1, v->length - 1 ));
				let inline = M.Inline.Text((a, M.Meta.none));
				let content = M.Inline.Strikethrough.make(inline);
				M.Inline.Ext_strikethrough((content, M.Meta.none))
			| _ => InlineCore.(skel->parse(k))
			}
		}
	}

	module Inline {
		include InlineExt

		let rec parse' = skel => {
			skel->parse(parse')
		}

		let parse = parse'
	}

	module Block {
		include M.Block

		let rec parse = skel => {
			switch (skel##"type") {
			| "root" =>
				let children = Array.map(parse, skel##"children") |> Array.to_list
				and meta = M.Meta.none
				M.Block.Blocks((children, meta))
			| "code" =>
				let info_string =
					(skel##"meta") |> Js.Null.toOption |> Option.map(x => (x, M.Meta.none))
				and lines = parse_block_lines(skel)
				and meta = M.Meta.none
				M.Block.Block_Code_block((M.Block.Code_block.make(~info_string?, lines), meta))
			| "heading" =>
				let level = skel##"depth"
				and inline = skel##"children"->Array.get(0)->Inline.parse
				and meta = M.Meta.none
				M.Block.Block_Heading((M.Block.Heading.make(~level, inline), meta))
			| "paragraph" =>
				let parts = skel##"children" |> Array.map(Inline.parse) |> Array.to_list
				let parts = M.Inline.Inlines((parts, M.Meta.none))
				M.Block.Block_Paragraph((M.Block.Paragraph.make(parts), M.Meta.none))
			| "html" =>
				let content = [(skel##"value", M.Meta.none)]
				and meta = M.Meta.none;
				M.Block.Block_Html_block((content, meta))
			| "list" =>
				let type_ = skel##"ordered" ? `Ordered((0, '-')) : `Unordered('-')
				and content = (skel##"children") |> Array.to_list |> List.map(parse_list_item);
				M.Block.List((M.Block.List'.make(type_, content), M.Meta.none))
			| "thematicBreak" => M.Block.Block_Thematic_break((M.Block.Thematic_break.make(), M.Meta.none))
			| s => failwith("unknown remark block of type '"++s++"'")
			}
		}

		and parse_list_item = skel => {
			assert(skel##"type" == "listItem");
			let content = M.Block.List_item.make(skel##"children"[0]->parse)
			and meta = M.Meta.none;
			(content, meta)
		}

		and parse_block_lines = skel =>
			skel##"value" |> String.split_on_char('\n') |> List.map(x => (x, M.Meta.none))

	}

	module Doc {
		let of_string = (~strict: bool, s) => {
			ignore(strict);
			let skel = Unified.(make()
				->use(Remark.parse)
				->parse(s));
			Js.Console.log2("skel", skel);
			((Block.parse(skel), s) : doc)
		}

		let block = ((skel, _s)) => {
			skel
		}
	}
}
