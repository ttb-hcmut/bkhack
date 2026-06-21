#import "/article": *
#import "@local/diagramming:0.1.0"
#import "@preview/cetz:0.5.2"
#import "@preview/fletcher:0.5.8": *
#set cite(style: "alphanumeric")

#lorem(20)
Given a pair of two strings, . This problem can be restated as: what is the _longest unchanged part_, or _LUP_ #fn[also known in literature as _longest common substring_ (LCS)], between them?\
  Based on Myer's diff algorithm @myers-ond.\
  The most common use case of diffing is to compare source code, and to apply patches. For these use case, diffs are split per line #fn[speculation: a possible reason is that, historically, most (UNIX) tools work with textual data per line, for example `grep`.]. However, since our use case of diffing is markdown documents, and as confirmed through UX testing, we find it most useful to diff per word.

#let text-removed(it, ..style) = {
  highlight(fill: color.transparentize( color.rgb("#bb1133") , 90%), text(it, fill: color.rgb("#990011")), ..style)
}

#let text-added(it, ..style) = {
  highlight(fill: color.transparentize( color.rgb("#00bb66") , 90%), text(it, fill: color.rgb("#009955")), ..style)
}

#quote[
  Tung, Tuong, Bao.
]

#quote[
  Tung, Tuong, Khang.
]

#quote[
#text-removed[Tung, Tuong, Bao.]\ 
#h(4pt)#text-added[Tung, Tuong, Khang.]
]

#quote[
  Tung, Tuong, #text-removed[Bao]#text-added[Khang].
]\
  And sometimes per sentence. #lorem(20)

#quote[
  TTB-HCMUT is an indie developer group. We make experimental softwares.
]

#quote[
  TTB-HCMUT is an indie developer group. We research embedded softwares and AI applications.
]

#quote[
  TTB-HCMUT is an indie developer group. We #text-removed[make] #text-removed[experimental] #text-added[research] #text-added[embedded] softwares #text-added[and] #text-added[AI] #text-added[applications].
]

#quote[
  TTB-HCMUT is an indie developer group. #text-removed[We make experimental softwares]#text-added[We research embedded softwares and AI applications].
]

#diagram(
  spacing: (10mm, 5mm),
  node((0, 0), [text]),
  edge("-|>", label-side: left, label: [string disassembling]),
  node((0, 1), [tokens]),
  edge("-|>", label-side: left, label: [algorithm]),
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
Utilizing `fiber` @bkhack:fiber, we managed to offload the  parallelize the running
== Deep parallelization
can our Myer-based algorithm be optimized or changed to have run for branching paths?
// rated <--n:n--> comments

#bibliography(title: none, "works.bib")

// vi: set nowrap:
