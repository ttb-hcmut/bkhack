open Js__markdown
module M = Melange__cmarkit.Cmarkit

module Cmarkit_html {
	let renderer = (~safe: bool, ()) => () => {
		ignore(safe);
		Unified.(make()
			->use(Remark.parse)
			->use(Remark.rehype)
			->use(Rehype.sanitize)
			->use(Rehype.stringify))
	}
}

module Cmarkit_renderer {
	let doc_to_string = (renderer, (_skel, s)) => {
		renderer()->Unified.process'(s)->string
	}
}

module Cmarkit {
	module Inline {
		include M.Inline

		let parse = skel =>
			switch (skel##"type") {
			| "text" => M.Inline.Text((skel##value, M.Meta.none))
			| s => failwith("unknown remark inline of type '"++s++"'")
			}
	}

	module Block {
		include M.Block

		let rec parse = skel =>
			switch (skel##"type") {
			| "root" =>
			{ let children = Array.map(parse, skel##"children") |> Array.to_list
				and meta = M.Meta.none
				M.Block.Blocks((children, meta)) }
			| "heading" =>
			{ let level = skel##"depth"
				and inline = skel##"children"->Array.get(0)->Inline.parse
				and meta = M.Meta.none
				M.Block.Block_Heading((M.Block.Heading.make(~level, inline), meta)) }
			| "paragraph" =>
			{ let parts = skel##"children" |> Array.map(Inline.parse) |> Array.to_list
				let parts = M.Inline.Inlines((parts, M.Meta.none))
				M.Block.Block_Paragraph((M.Block.Paragraph.make(parts), M.Meta.none)) }
			| s => failwith("unknown remark block of type '"++s++"'")
			}

	}

	module Doc {
		let of_string = (~strict: bool, s: string) => {
			ignore(strict);
			let skel = Unified.(make()
				->use(Remark.parse)
				->parse(s));
			(Block.parse(skel), s)
		}

		let block = ((skel, _s)) => {
			skel
		}
	}
}
