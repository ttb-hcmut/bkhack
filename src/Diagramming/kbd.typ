#import "colors.typ"

#let tab() = [#box(inset: (bottom: 0.1em), text(font: "Liberation Serif", size: 0.6em, "["))#text(font: "Liberation Mono", [T#h(-0.05em)A#h(-0.05em)B])#box(inset: (bottom: 0.1em), text(font: "Liberation Serif", size: 0.6em, "]"))]

#let escape() = [#box(inset: (bottom: 0.1em), text(font: "Liberation Serif", size: 0.6em, "["))#text(font: "Liberation Mono", [E#h(-0.05em)S#h(-0.05em)C])#box(inset: (bottom: 0.1em), text(font: "Liberation Serif", size: 0.6em, "]"))]

#let ctrl-(it) = [#box(text(font: "Liberation Serif", size: 0.7em, "<"))#text(font: "Liberation Mono", "C")#text(fill: color.transparentize(color.rgb("#000"), 50%), "-")#text(font: "Liberation Serif", it)#box(text(font: "Liberation Serif", size: 0.7em, ">"))]

#let meta-(it) = [#box(text(font: "Liberation Serif", size: 0.7em, "<"))#text(font: "Liberation Mono", "M")#text(fill: color.transparentize(color.rgb("#000"), 50%), "-")#text(font: "Liberation Serif", it)#box(text(font: "Liberation Serif", size: 0.7em, ">"))]

#let ret() = [#box(inset: (bottom: 0.1em), text(font: "Liberation Mono", size: 0.6em, "["))#text(font: "Liberation Mono", "RET")#box(inset: (bottom: 0.1em), text(font: "Liberation Mono", size: 0.6em, "]"))]

#let cmd(x) = x

#let RET = ret
#let enter = ret
#let return_ = ret

#let rune(it) = it.join(" ")

/// This function returns a keyboard key element
///
/// ```example
/// #key([Ctrl])
/// #key("Alt")
/// ```
/// 
/// - c (string,content): The label of the key
#let key(c) = { text(font: "Liberation Serif", c) }

/// This function returns a Combination of keyboard key elements and typed commands
///
/// ```example
/// #keys([M],[x],"package-refresh-contents",[RET])
/// ```
/// 
/// - k (string,content): The label of the key combos where string arguments are displayed as plain text and content is displayed as keyboard key element
#let keys(style: "flat", ..k) = {
  let c = {
    for c in k.pos() {
      if type(c) == content [
        #key(c)
      ] else [
        #text(c)
      ]
    }
  }
  if style == "fancy" {
    box(
      box(c, stroke: colors.cream-2 + 0.5pt, radius: 2pt, inset: (left:2pt,right:2pt), outset: (top:2pt,bottom:2pt), fill: color.rgb("#fff")),
      stroke: colors.cream-2 + 1pt, radius: 2pt, outset: (top:2pt,bottom: 3pt), fill: colors.cream-2
    )
  } else if style == "flat" {
    box(c, stroke: colors.cream-2 + 0.5pt, radius: 2pt, inset: (left:2pt,right:2pt), outset: (top:2pt,bottom:2pt), fill: color.rgb("#fff"))
  } else if style == "basic" {
    box(
      box(c, radius: 2pt, inset: (left:0pt,right:0pt), outset: (top:2pt,bottom:2pt), fill: none),
      radius: 2pt, outset: (top:2pt,bottom: 3pt), fill: none
    )
  }
}


// vi: set nowrap:
