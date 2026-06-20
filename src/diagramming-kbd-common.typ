#let tab() = [#box(inset: (bottom: 0.1em), text(font: "Liberation Serif", size: 0.6em, "["))#text(font: "Liberation Mono", [T#h(-0.05em)A#h(-0.05em)B])#box(inset: (bottom: 0.1em), text(font: "Liberation Serif", size: 0.6em, "]"))]

#let escape() = [#box(inset: (bottom: 0.1em), text(font: "Liberation Serif", size: 0.6em, "["))#text(font: "Liberation Mono", [E#h(-0.05em)S#h(-0.05em)C])#box(inset: (bottom: 0.1em), text(font: "Liberation Serif", size: 0.6em, "]"))]

#let ctrl-(it) = [#box(text(font: "Liberation Serif", size: 0.7em, "<"))#text(font: "Liberation Mono", "C")#text(fill: color.transparentize(color.rgb("#000"), 50%), "-")#text(font: "Liberation Serif", it)#box(text(font: "Liberation Serif", size: 0.7em, ">"))]

#let meta-(it) = [#box(text(font: "Liberation Serif", size: 0.7em, "<"))#text(font: "Liberation Mono", "M")#text(fill: color.transparentize(color.rgb("#000"), 50%), "-")#text(font: "Liberation Serif", it)#box(text(font: "Liberation Serif", size: 0.7em, ">"))]

#let ret() = [#box(inset: (bottom: 0.1em), text(font: "Liberation Mono", size: 0.6em, "["))#text(font: "Liberation Mono", "RET")#box(inset: (bottom: 0.1em), text(font: "Liberation Mono", size: 0.6em, "]"))]

#let cmd(x) = x

#let RET = ret
#let enter = ret
#let return_ = ret

// vi: set nowrap:
