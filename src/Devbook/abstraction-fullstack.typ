#import "/article": *
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
#fletcher.diagram({
  import fletcher: *
  node((0,0), [library `bkhack`], stroke: 1pt)
  edge("-|>")
  node((0,1), `melange.emit`, shape: shapes.rect, stroke: 1pt)
  node(enclose: ((-1, -0.5), (1, 2)), [`$ dune build`], stroke: teal)
  edge("-|>")
  node((0,3), `$ bundle`, stroke: 1pt)
  node((2,2), [public dir], stroke: 1pt)
  edge((2,2), (0,3), "-|>")
  node((-2,2), [service], stroke: 1pt)
  edge("-|>")
  node((-2,3), `$ bundle-d`, stroke: 1pt)
})

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

== Design with escape-hatches in mind, self-recovery
Even with the goal of a full-stack framework in mind, we must admit the reality that it is hard and is an contextual evolving process to design an abstraction, we embrace it that our system is a living evolving one. And the view of a full-stack abstraction is not always good, sometimes it's good to have clear separation of responsibilities. And the goal isn't uniformly shared by all developers.\
  Hence, while the core app is a Reason front-end bundle, there are other aspects of the app. The styling of the app is shifted towards the static front-end bundle. The serving of data is shifted towards the service bundle of the app. The final-state, ideal of the app is one where only the core remains. The current reality is that there are multiple aspects of the app, and we try to shrink these aspects as much as we could, while upholding functional and non-functional requirements.\
  APIs will be eventually converted from references and fetches to embeddings and abstract algebras. In the case when conversion is difficult, or when there is disagreement, we will be fine with the way things are. In other words, when the full-stack abstraction fails, it can self-recover to by defaulting to a reliable raw, concrete implementation.

// vi: set nowrap:
