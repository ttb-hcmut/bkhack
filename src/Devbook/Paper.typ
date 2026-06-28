#let doc = it => {
  set heading(numbering: none,  outlined: true, supplement: [#text(weight: 900, fill: rgb("#3851A4"))[§]#h(-0.4em)])
  set cite(style: "alphanumeric")
  show heading: it => {
    if it.level == 3 {
      set text(size: 0.9em); it
    } else { it }
  }
  it
}

// vi: set nowrap:
