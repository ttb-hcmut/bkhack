#import "/article": *
#import "Paper.typ" as paper
#import "Vocab.typ" as o
#import "@preview/fletcher:0.5.8" as fletcher
#import "@preview/cetz:0.5.2"
#import "@local/diagramming:0.1.0"
#show: paper.doc
#set raw(syntaxes: ("reason.sublime-syntax")/* , theme: "quiet.tmTheme" */)
#let nl = $ \ &#v(-1em)\ $
#title[= Abstraction full-stack]
Previously, we discussed the motivation of abstraction and the science
of them. #lorem(20) In this article, we present a more concrete motivation
. An application of abstraction in application development. #fn[currently
, it is at POC stage, it is a groundwork where more can be developed.]\
  A conventional view of application development would be that the client
and the server form an architecture where the server is the orchestrator
and the client merely fetches and presents. A full-stack developer,
however, would say that this view of the application is not necessary:
the programming of the application is much more abstract and high-level
and is often quite syntactically different from the implementation code
, and that this difference should be reduced. You may perform a fetch
to tier 2--which fetches tier 3--to get some data then deserializes it
; as visualized by a sequence diagram. But your brain may see it as a
single orchestration where data flows from tier 3 to a state variable
in tier 1. At the core of this system is the concept of _flow_--not
the sort of instructions that one might build into a machine or write
a computer program, but the grammar to describe and declare between humans.\
  For example, a Reason code may orchestrate that data (pull request
items filtered by $"target-post-id"$) shall flow from a source to the current
application. It does so by opening a _portal_--written as a Reason
functor--into an abstract data repository then defines a _flow_:
#let mkbox(inset: 0em, p) = context box(inset: inset, {
  cetz.canvas({
    import cetz.draw: *
    let p-length = measure(p)
    cetz.decorations.brace((-0.17, 0pt), (-0.17, p-length.height + 1pt), outer-curvyness: 100%)
    content((0, 0), (p-length.width, p-length.height), name: "ds", p)
  })
})
#let ghost(it) = text(fill: diagramming.colors.cream-2, it)
/// FrontPage Light Blue
#let wire(it)  = text(fill: diagramming.colors.blue-3, it)
$
&"module" "At-repo"_0\ &#v(-1em)\ 
&(U : { #h(2pt) "let" italic("tgtpost") : "id" #h(2pt) }, #text(fill: diagramming.colors.cream-2, $S$) : "Entities".S)\ &#v(-1em)\ 
&#mkbox($
  &"open" #ghost($S$)  #h(4cm + 1pt) #box(inset: (bottom: -2pt - 2pt, top: -2pt), box(stroke: 0.2pt, inset: (bottom: 2pt, top: 2pt, left: 2pt, right: 2pt), text(font: "Libertinus Serif")[server mode]))\ &#v(-1em)\ 
  &"let" "rec" q = (dot) =>\ &#v(-1em)\ 
  &#h(8pt)"foreach"(italic("prs'"), #h(4pt) o =>\ &#v(-1em)\ 
  &#h(8pt)"where"(o#h(-1pt)->#h(-1pt)"Pr"."postid" #box(height: 0.7em, $=_@$) "str"(U.italic("tgtpost")), (dot) =>\ &#v(-1em)\ 
  &#h(8pt)"yield"(o)))\ &#v(-1em)\ 
  &"and" italic("prs'") #h(1pt) = (dot) => "table"(#[`shared-pr`], "prs"())
$)
$
// ```reason
// module At_repo0(S : {
//   include Entities.S
//   let tgt_post_id : string })
// { open S
//   let rec q = () =>
//     foreach(prs') @@ o =>
//     where(Pull_request.post_id(o) =@ str(tgt_post_id)) @@ () =>
//     yield(o)
//   and prs' = () => table @@ ("pullrequest", prs())
// }
// ```
and this orchestration is then used, #lorem(15)
#let promise-star = text(fill: diagramming.colors.yellow-2, math.star)
#let let_(ext: none) = {
  if ext == none { $"let" #h(2pt)$ } else {
    show math.star: it => text(size: 16pt, it)
    $"let"_#ext$
  }
  h(2pt)
}
$
&#box(width: 100%, inset: (bottom: -2pt - 2pt, top: -2pt),
  align(right,
    box(stroke: 0.2pt, inset: (bottom: 2pt, top: 2pt, left: 2pt, right: 2pt), text(font: "Libertinus Serif")[client mode])
  )
)\ &#v(-1.8em)\
&"let"^("@""react"."component") "make" = (dot) =>\ &#v(-1em)\ 
&#mkbox(
  $
  &#v(0em)\ 
  &dots\ &#v(-1em + 0.3em)\ 
  &"let" "open" "Remote" ("module" "Env")\ &#v(-1em)\ 
  &"React"."watch"_1 (t) #h(1pt) #scale(x: 80%, y: 70%, rotate(-90deg, text(stroke: 0.1pt, math.triangle))) #h(1pt) (dot) =>\ &#v(-1em)\ 
  &#mkbox(
    $
    &#let_(ext: promise-star) "prs" = "Buf-read"."of-flow"("module"\ &#v(-1em)\ 
    &#h(12pt) "At-repo"_0({ #h(1pt) "let" italic("tgtpost") = t #h(1pt) }))\ &#v(-1em)\ 
    &#v(0em)\ 
    &dots\ &#v(0em)\ 
    $
  )
  $
)
$
// ```reason
// [@react.component]
// let make = () => {
//   ...
//   let open Remote(module Env);
//   watch0(() => Promise.Syntax.({
//     let* prs = Buf_read.of_flow(module At_repo0);
//     ...
//   }));
// }
// ```
This orchestration syntax is highly expressive, it resembles a direct
relational data query, the module $S$ in the fuctor $"At-repo"_0$ provides
all entities and relationships symbol vocabulary in the #o.bkhack system that a programmer
can use. This is an abstraction. In the implementation layer, each
$"At-repo"_0$, upon plug-in to a $"Buf-read"."of-flow"$, compiles to specialized
and secured fetch code.\
  This has been one example, being data repository portal #fn[currently, a POC implementation of this exists, called _free sql_]
. Other kinds include stylesheet portal, pagegen portal, fiber @bkhack:fiber, and server-side react components.\
  *Conceptual layers*. The goal of an abstraction isn't to hide all details underneath, but to provide an intuitive building block on top of other building blocks which the programmer can choose to rely on. For abstraction, these building blocks / layers include
#cetz.canvas({
  import cetz.draw: *
  let gap = 0.2
  let b-width = 3.0
  let colwidth = 7.65
  let b-height = 0.7
  let bl(i, title, side: none) = {
    let name = "bl"+repr(i)
    rect((0,b-height*i), (b-width,b-height*(i+1)), name: name)
    content(name, title)
    if side != none {
      content((b-width+gap,b-height*i), (colwidth,b-height*(i+1)), pad(bottom: 4pt, align(horizon, side)))
    }
  }
  let bl-et-cetera(i) = {
    line((0,b-height*i), (b-width,b-height*i))
    line((0,b-height*(i+0.5)), (b-width,b-height*(i+0.5)))
    line((0,b-height*(i+1)), (b-width,b-height*(i+1)))
  }
  bl(1, [Algebra layer], side: [promise, fiber @bkhack:fiber, portal])
  bl(0, [Application layer], side: [worker, fetch, websocket])
  bl(-1, [Transport layer], side: [tcp, udp])
  bl-et-cetera(-2)
})
#lorem(30)
#pagebreak()
== Code mechanization
_staging_ _mode_ Boundaries. Structure items. shared or non-shared lexical scopes. _Functors_. _Comptime_. _Biphasic programming_ @exploring-biphasic-programming.

#box(stroke: 0.2pt, [compiler mode])

#box(stroke: 0.2pt, [server mode])

#box(stroke: 0.2pt, [client mode])

Implementation is PPX layer.
The artifacts are called _generatives_ because they aren't what Dune expect them to be Reason code. The $"Gen"$ module.
The Reason-to-JavaScript code is further optimized by _webpacking_. _code splitting_ _code sharing_

Implementation is Reason symbol algebras. _orchestrates_ _choreographs_ _flows_

Implementation is the build system declarations.

_compiler_ _graph_

*Generatives are heterogeneous*.
_Heterogeneity_, specifically _implicit heterogeneity_, as an aspect of a full-stack system, is the idea that even when the full-stack system is programmable in one homogeneous unit, its output doesn't have to be homogeneous but instead can be hetergeneous. The #o.bkhack system, albeit full-stack, is being split into a front-end part and an optional back-end part. Within this front-end part, the Reason code is one homogeneous source-tree, but is actually being implicitly split into multiple page outputs (multi-page application) as well as being generative of stylesheet (`cssgen`) and page layout (`pagegen`) static asset. This implicit heterogeneity ensures zero-cost abstraction.
  // This heterogeneity is made possible because our system is built before deployment--it is staged and has layers.
#pagebreak()
== First-class build process
We thought about implementing an intelligent compiler that will work
with the above programs, the user can hand-off (@dune-version-1). However, some of these
ideas would violate the purity philosophy of the build system Dune, like the previously-mentioned generatives.
Ultimately, we embrace Dune as a _build system langugage_ that the user
--not the framework implementer--controls. Any extensions to implement
the full-stack system should be in the form of new idioms of Dune that
the user can use (@dune-version-2).\
  For example, if
$
&("rule"#nl
& #h(8pt) ("deps" ("inc" ))
$
The previous build system is based on processes. Dune model is based on build components

Optimization is done per build component tools.

We extended Dune to support Typst packages.

#place(auto, scope: "parent", float: true)[
  #figure(caption: [Version 1 of the build system for #o.bkhack. Notice that there are multiple _build subsystems_ in orchestration.])[
    #fletcher.diagram({
      import fletcher: *
      let public_dir = (pos: (1,0.5), label: [public dir])
      let cmd-bundle = (pos: (2,0), label: `$ bundle`)
      node((0,0), [library `bkhack`], stroke: 1pt)
      edge("-|>")
      node((1,0), `melange.emit`, shape: shapes.rect, stroke: 1pt)
      node(enclose: ((0, 0), (1,0)), [`$ dune build`], shape: shapes.pill, stroke: teal)
      edge("-|>")
      node(cmd-bundle.pos, cmd-bundle.label, shape: shapes.pill, stroke: 1pt)
      node(public_dir.pos, public_dir.label, stroke: 1pt)
      edge(public_dir.pos, cmd-bundle.pos, "-|>")
      node((-2,0.2), [service dir], stroke: 1pt)
      edge("-|>")
      node((-1,0.2), `$ bundle-d`, shape: shapes.pill, stroke: 1pt)
    })
  ] <dune-version-1>
]

#place(auto, scope: "parent", float: true)[
  #figure(caption: [Version 2 of the build system for #o.bkhack. Notice that there are no more many build subsystems, but only one unifying build system that is Dune. Some steps, which previously required other subsystem, are now remade as Dune rules.])[
    #fletcher.diagram({
      import fletcher: *
      node((0,0), [library `bkhack`], stroke: 1pt)
      edge("-|>")
      node((0,1), `melange.emit`, shape: shapes.rect, stroke: 1pt)
      edge("-|>")
      node((0,2), `rule bundle`, shape: shapes.rect, stroke: 1pt)
      node((1,1), `sourcetree Static`, shape: shapes.rect, stroke: 1pt)
      edge((1,1), (0,2), "-|>")
      node((2,1), `copy_files Service/...`, shape: shapes.rect, stroke: 1pt)
      edge("-|>")
      node((2,2), `rule bundle-d`, shape: shapes.rect, stroke: 1pt)
      node(enclose: ((-1, -0.5), (2, 2)), [`$ dune build`], stroke: teal)
    })
  ] <dune-version-2>
]
#pagebreak()
== Related works
Since #o.bkhack is written for a quarter and a half in Reason, its first natural source of inspiration was the Eliom framework @eliom from OCaml. Eliom is a multi-tier framework for OCaml. A single source code file can contain both server and client code, the two tiers don't necessarily interact but programmers can write mixed modules that can be used at both tiers with mixed implementations. Eliom is grounded in semantic proofs. Like Eliom, #o.bkhack restricts tier boundaries to structures instead of expressions. Unlike Eliom, #o.bkhack focuses on high-level flow algebra.

$
&"let"_#ghost("server") "a"
$

The reactive programming engine of #o.bkhack is React, and for React it boasts a specification for server components. React server component @rsc:server-components Functions @rsc:server-functions

Electric Clojure @electric-clojure in eclj, any expression can be split into client or back-end or more, but for bkhack we restrict to top-level expressions and modules as both to ease code splitting implementation and to make scoping less black-magic. Also, eclj fuses react programming cross-tier, bkhack we don't enforce that reactive prorgamming paradigm and currently it's only in front-end in the form of ReactJS, combined with data-flow programming from the data portal... but it would be nice.

#[
#let box = std.box.with(stroke: 0.2pt, inset: (x: 4pt, y: 4pt))
#box[
$
#text(font: "Libertinus Serif")[client mode] & (e\/"client")#nl
#text(font: "Libertinus Serif")[server mode] & #ghost($($)e\/#ghost("server")#ghost($)$)#nl
#text(font: "Libertinus Serif")[diff mode]   & #wire($($)e\/#wire("diff-by")#wire($)$)
$
]
]
$
&(e\/"defn" "Pull-request-view" [#h(1pt)]#nl 
& #h(8pt) (e\/"client"#nl
& #h(8pt) #h(8pt) ("dom"\/"h"_1 ("dom"\/"text" “#text(font: "Libertinus Serif", "pull requests")”))#nl
& #h(8pt) #h(8pt) ("let" [ #h(4pt) italic("db") #ghost($($)e\/#ghost("server") (e\/"watch" italic("conn") ) #ghost($)$)   #nl
& #h(8pt) #h(8pt) #h(28pt) italic("search") ("dom"\/"input" ("dom"\/"On" #[`input`]#nl
& #h(8pt) #h(8pt) #h(28pt) #h(4pt) \#(-> %."target"."value") #h(2pt) “” #h(2pt) )) #h(4pt) ]#nl
& #h(8pt) #h(8pt) #h(8pt) ("dom"\/"table"#nl
& #h(8pt) #h(8pt) #h(8pt) #h(8pt) (e\/"for" [ #h(4pt) italic("record") #ghost($($)e\/#ghost("server") #wire($($)e\/#wire("diff-by")#nl
& #h(8pt) #h(8pt) #h(8pt) #h(8pt) #h(38pt) #h(4pt) #(`:db/id`) ("prs" italic("db") italic("search")) #wire($)$) #ghost($)$) #h(4pt) ]#nl
& #h(8pt) #h(8pt) #h(8pt) #h(8pt) #h(8pt) ("dom"\/"tr" ("dom"\/"text" ("pr-str" italic("record"))))))
$
// Ruby on Rails, Expo, Phoenix, Eliom
#pagebreak()
== Addendum: Design with escape-hatches in mind, self-recovery
Even with the goal of a full-stack framework in mind, we must admit the reality that it is hard and is an contextual evolving process to design an abstraction, we embrace it that our system is a living evolving one. And the view of a full-stack abstraction is not always good, sometimes it's good to have clear separation of responsibilities. And the goal isn't uniformly shared by all developers.\
  Hence, while the core app is a Reason front-end bundle, there are other aspects of the app. The styling of the app is shifted towards the static front-end bundle. The serving of data is shifted towards the service bundle of the app. The final-state, ideal of the app is one where only the core remains. The current reality is that there are multiple aspects / bundles of the app, and we try to shrink these aspects / bundles as much as we could, while upholding functional and non-functional requirements.\
  APIs will be eventually converted from references and fetches to embeddings and abstract algebras. In the case when conversion is difficult, or when there is disagreement, we will be fine with the way things are. In other words, when the full-stack abstraction fails, it can self-recover by defaulting to a reliable raw, concrete implementation.
#cetz.canvas({
  import cetz.draw: *
  let gap = 0.2
  let b-width = 3.0
  let colwidth = 7.65
  let b-height = 0.7
  let bl(i, title, side: none) = {
    let name = "bl"+repr(i)
    rect((0,b-height*i), (b-width,b-height*(i+1)), name: name)
    content(name, title)
    if side != none {
      content((b-width+gap,b-height*i), (colwidth,b-height*(i+1)), pad(bottom: 4pt, align(horizon, side)))
    }
  }
  let bl-et-cetera(i) = {
    line((0,b-height*i), (b-width,b-height*i))
    line((0,b-height*(i+0.5)), (b-width,b-height*(i+0.5)))
    line((0,b-height*(i+1)), (b-width,b-height*(i+1)))
  }
  bl(1, [Data portal])
  bl(0, [Fetch])
  bl-et-cetera(-1)
})
#bibliography(title: none, "works.bib")
// vi: set nowrap:
