#let tab = [#box(stroke: 1pt, radius: 1pt, outset: (bottom: 0.1em), inset: (top: 0.2em, bottom: 0.1em, left: 0.1em, right: 0.1em), text(size: 0.7em, font: "Liberation Mono", [Tab]))#h(0.2em)]

#let escape = [#box(stroke: 1pt, radius: 1pt, outset: (bottom: 0.1em), inset: (top: 0.2em, bottom: 0.1em, left: 0.1em, right: 0.1em), text(size: 0.7em, font: "Liberation Mono", [Esc]))#h(0.2em)]

#let ctrl = [#box(stroke: 1pt, radius: 1pt, outset: (bottom: 0.1em), inset: (top: 0.2em, bottom: 0.1em, left: 0.1em, right: 0.1em), text(size: 0.7em, font: "Liberation Mono", [Ctrl]))#h(0.2em)]

#let ctrl-(it) = [#box(stroke: 1pt, radius: 1pt, outset: (bottom: 0.1em), inset: (top: 0.2em, bottom: 0.1em, left: 0.1em, right: 0.1em), text(size: 0.7em, font: "Liberation Mono", [Ctrl]))#h(0.2em)-#it]

#let rune(it) = it.join(" ")

/// This function returns a keyboard key element
///
/// ```example
/// #key([Ctrl])
/// #key("Alt")
/// ```
/// 
/// - c (string,content): The label of the key
#let key(
  c
  ) = {
  box(box(c, stroke: 0.5pt, radius: 2pt, inset: (left:2pt,right:2pt), outset: (top:2pt,bottom:2pt), fill: rgb("#FAFAFA")), stroke: 0.5pt, radius: 2pt, outset: (top:2pt,bottom: 3pt),fill:black)
}
/// This function returns a Combination of keyboard key elements and typed commands
///
/// ```example
/// #keys([M],[x],"package-refresh-contents",[RET])
/// ```
/// 
/// - k (string,content): The label of the key combos where string arguments are displayed as plain text and content is displayed as keyboard key element
#let keys(..k) = {
  box(
    for c in k.pos() {
      if type(c) == content [
        #key(c)
      ] else [
        #text(c,font:"Liberation Mono")
      ]
    }
    , radius: 2pt, inset: (left:2pt,right:2pt), outset: (top:4pt,bottom:5pt), fill: rgb("#EEEEEE")
  )
}

// vi: set nowrap:
