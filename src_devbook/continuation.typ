#import "/article": *
#title[= Continuation and safety]
== Related works
Bonsai @bonsai-github is a library for general-purpose reactive programming and with a focus on reactive user interface. It belongs to same category of reactive-programming libraries like Reason React. One of the central design points of Bonsai is that it has an applicative programming interface. This applicative enforces the concept of incremental computation--through ```ocaml 't Computation.t```--and generalized side effects--through ```ocaml 't Effect.t```--which can mean an async operation (```ocaml 't Lwt.t```) or #lorem(10). And users have to use specific let-bindings to write with these applicatives. This applicative-based design is very strict. Therefore, a consequence is that developers require a learning curve to use this library.

#bibliography(title: none, "works.bib")
// vi: set nowrap:
