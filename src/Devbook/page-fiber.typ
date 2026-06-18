#import "/article": *
#import "vocab.typ" as o
#lorem(30) We introduced *`fiber`* as a library that implements _structured concurrency_--a concurrency algebra for internal #o.bkhack modules. It is an extension of JavaScript Promise with _control capabilities_ i.e. to cancel and perform group operations.\
  Since #o.bkhack is deployed to the browser, the algebra was a much-needed abstraction for parallelization using Workers. Below, we discuss the design and implementation of the algebra.
== Related works
Dune's `fiber`. The Cancel module. #lorem(10) Eio's Fiber.  #lorem(10)
== Foundation
== Design
  The _module layer_.\
  The _ppx layer_.\
  The _code extraction & generation layer_
// vi: set nowrap:
