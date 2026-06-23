#import "/article": *
#import "Vocab.typ" as o
#title[= Abstracting in-browser parallelism and more with fibers]
#lorem(30) We introduced *`fiber`* as a library that implements structured
concurrency--a concurrency algebra for internal #o.bkhack modules. It
is an extension of JavaScript Promise equipped with _control capabilities_
i.e. to cancel and perform group actions.\
  Since #o.bkhack is deployed to the browser, the algebra was a much
-needed abstraction for parallelization using Workers. Below, we discuss
the design and implementation of the algebra.
== Related works
Dune's `fiber`. The Cancel module. #lorem(10) Eio's Fiber.  #lorem(10)
== Design
  The _module layer_.\
  The _ppx layer_.\
  The _code extraction & generation layer_
// vi: set nowrap:
