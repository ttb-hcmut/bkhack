#import "/article": *
#import "vocab.typ" as o
#import "@preview/fletcher:0.5.8" as fletcher
#title[= Abstraction full-stack]
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
a computer program, but the grammar to describe and declare between humans.
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
  Hence, while the core app is a Reason front-end bundle, there are other aspects of the app. The styling of the app is shifted towards the static front-end bundle. The serving of data is shifted towards the service bundle of the app. The final-state, ideal of the app is one where only the core remains. The current reality is that there are multiple aspects of the app, and we try to shrink these aspects as much as we could, while upholding functional and non-functional requirements.\
  APIs will be eventually converted from references and fetches to embeddings and abstract algebras. In the case when conversion is difficult, or when there is disagreement, we will be fine with the way things are. In other words, when the full-stack abstraction fails, it can self-recover by defaulting to a reliable raw, concrete implementation.
== Heterogeneous
_Heterogeneity_, specifically _implicit heterogeneity_, as an aspect of a full-stack system, is the idea that even when the full-stack system is programmable in one homogeneous unit, its output doesn't have to be homogeneous but instead can be hetergeneous.\
  The #o.bkhack system, albeit full-stack, is being split into a front-end part and an optional back-end part. Within this front-end part, the Reason code is one homogeneous source-tree, but is actually being implicitly split into multiple page outputs (multi-page application) as well as being generative of stylesheet (`cssgen`) and page layout (`pagegen`) static asset.\
  This implicit heterogeneity ensures _zero-cost abstraction_.\
  This heterogeneity is made possible because our system is built before deployment--it has a _pipeline_
// vi: set nowrap:
