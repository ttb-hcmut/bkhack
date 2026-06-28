#import "/article": *
#import "Vocab.typ" as o
#import "@preview/fletcher:0.5.8" as fletcher
#import "@preview/cetz:0.5.2"
#set raw(syntaxes: ("reason.sublime-syntax")/* , theme: "quiet.tmTheme" */)
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
functor--into an abstract data repository then defines a flow, like so
```reason
module At_repo0(S : {
  include Entities.S
  let tgt_post_id : string })
{ open S
  let rec q = () =>
    foreach(prs') @@ o =>
    where(Pull_request.post_id(o) =@ str(tgt_post_id)) @@ () =>
    yield(o)
  and prs' = () => table @@ ("pullrequest", prs())
}
```
and this orchestration is then used, #lorem(15)
```reason
[@react.component]
let make () => {
  ...
  let open Remote(module Env);
  watch0(() => Promise.Syntax.({
    let* prs = Buf_read.of_flow(module At_repo0);
    ...
  }));
}
```
This orchestration syntax is very expressive, it resembles a direct
relational data query, the module $S$ in the fuctor $"At-repo"_0$ provides
all entities and relationships symbol vocabulary in the #o.bkhack system that a programmer
can use. This is an abstraction. In the implementation layer, each
$"At-repo"_0$, upon plug-in to a $"Buf-read"."of-flow"$, compiles to specialized
and secured fetch code.\
  This has been one example, being data repository portal #fn[currently, a POC implementation of this exists, called _free sql_]
. Other kinds include stylesheet portal, pagegen portal, fiber @bkhack:fiber, and server-side react components
.
== Implementation conceptual layers
#lorem(30)
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
  bl(1, [Algebra layer], side: [promise, fiber, portal])
  bl(0, [Application layer], side: [worker, fetch, websocket])
  bl(-1, [Transport layer], side: [tcp, udp])
  bl-et-cetera(-2)
})
#lorem(30)
== Mechanics
_generatives_
_staging_
== First-class full-stack build process
@dune-version-1
#place(auto, scope: "parent", float: true)[
  #figure(caption: [Version 1])[
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
@dune-version-2
#place(auto, scope: "parent", float: true)[
  #figure(caption: [Version 2])[
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
== Design with escape-hatches in mind, self-recovery
Even with the goal of a full-stack framework in mind, we must admit the reality that it is hard and is an contextual evolving process to design an abstraction, we embrace it that our system is a living evolving one. And the view of a full-stack abstraction is not always good, sometimes it's good to have clear separation of responsibilities. And the goal isn't uniformly shared by all developers.\
  Hence, while the core app is a Reason front-end bundle, there are other aspects of the app. The styling of the app is shifted towards the static front-end bundle. The serving of data is shifted towards the service bundle of the app. The final-state, ideal of the app is one where only the core remains. The current reality is that there are multiple aspects / bundles of the app, and we try to shrink these aspects / bundles as much as we could, while upholding functional and non-functional requirements.\
  APIs will be eventually converted from references and fetches to embeddings and abstract algebras. In the case when conversion is difficult, or when there is disagreement, we will be fine with the way things are. In other words, when the full-stack abstraction fails, it can self-recover by defaulting to a reliable raw, concrete implementation.
== Heterogeneous
_Heterogeneity_, specifically _implicit heterogeneity_, as an aspect of a full-stack system, is the idea that even when the full-stack system is programmable in one homogeneous unit, its output doesn't have to be homogeneous but instead can be hetergeneous.\
  The #o.bkhack system, albeit full-stack, is being split into a front-end part and an optional back-end part. Within this front-end part, the Reason code is one homogeneous source-tree, but is actually being implicitly split into multiple page outputs (multi-page application) as well as being generative of stylesheet (`cssgen`) and page layout (`pagegen`) static asset.\
  This implicit heterogeneity ensures _zero-cost abstraction_.\
  This heterogeneity is made possible because our system is built before deployment--it is staged and has layers.
== Related works
Ruby on Rails, Expo, Phoenix, Eliom
#bibliography(title: none, "works.bib")
// vi: set nowrap:
