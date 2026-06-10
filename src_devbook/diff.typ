#import "/article": *
#import "@preview/cetz:0.5.2"
#import "@preview/fletcher:0.5.8": *

#lorem(20)

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

// rated <--n:n--> comments

#bibliography(title: none, "works.bib")

// vi: set nowrap:
