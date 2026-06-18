#import "/article": *
#import "@preview/cetz:0.5.2"
#import "@preview/fletcher:0.5.8": *

#lorem(20)
Given a pair of two strings, . This problem can be restated as: what is the _longest unchanged part_, or _LUP_ #fn[also known in literature as _longest common substring_ (LCS)], between them?\
  Based on Myer's diff algorithm @myers-ond.

#cetz.canvas({
  import cetz.draw: *
  content((0,0), (5,1))[Lorem ipsum dolor sit amet, consectetur]
})


#diagram(
  spacing: (10mm, 5mm),
  node((0, 0), [text]),
  edge("-|>", [string disassembling]),
  node((0, 1), [tokens]),
  edge("-|>", [algorithm]),
  node((0, 2), [changes])
)


== Fused diffing

#diagram(
  spacing: (10mm, 5mm),
  node((0, 0), [text]),
  edge("r,d,d,l", "-|>",
[contextual disassembling\
\+ algorithm], label-side: left),
  edge("-|>"),
  node((0, 1), [...]),
  edge("-|>"),
  node((0, 2), [changes]),
)

== Specialization
dedicated implementation as React component.
== Parallelization
Utilizing `fiber`, we managed to offload the  parallelize the running
// rated <--n:n--> comments

#bibliography(title: none, "works.bib")

// vi: set nowrap:
