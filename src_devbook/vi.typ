#import "/article": *
#import "./kbd.typ"
#import "@preview/cetz:0.5.1"
#import "@preview/finite:0.5.1": automaton
#set raw(syntaxes: ("reason.sublime-syntax")/* , theme: "quiet.tmTheme" */)
#set heading(numbering: "1.",  outlined: true, supplement: [#text(weight: 900, fill: rgb("#3851A4"))[§]#h(-0.4em)])
#show heading: it => {
  if it.level == 1 { set text(size: 0.85em); it }
  else if it.level == 2 { set text(size: 0.75em); it }
  else { it }
}
#set cite(style: "alphanumeric")
#let header(it) = text(weight: 700, [#(it)#h(0.2em)])
#title[= Vim motion]

#lorem(50)

#align(center)[
  #let layout = (
    modecmd: (0, 2),
    modenormal: (0, 0),
    modevisual: (2, 0),
    modeinsert: (0, -2.5)
  )
  #let labels = (
    modecmd: [cmd],
    modenormal: [nrm],
    modevisual: [vi],
    modeinsert: [ins],
  )
  #let cream-1 = color.rgb("#F5F7FF")
  #let cream-2 = color.rgb("#8F95AE")
  #let cream-3 = color.rgb("#636A8A")
  #let style = (
    modenormal: (stroke: cream-3, fill: cream-1),
    modecmd: (stroke: cream-3, fill: cream-1),
    modeinsert: (stroke: cream-3, fill: cream-1),
    modevisual: (stroke: cream-3, fill: cream-1),
    modenormal-modecmd: (angle: 0deg, dist: 9pt, curve: 1),
    modenormal-modeinsert: (angle: 0deg, dist: 9pt, curve: 1),
    modecmd-modenormal: (angle: 0deg, curve: 0),
    modevisual-modenormal: (angle: 0deg, curve: 0),
    modeinsert-modenormal: (angle: 0deg, curve: 0),
  )
  #let initial = "modenormal"
  #automaton(initial: initial, layout: layout, labels: labels, style: style, (
    modecmd: (modenormal: $ kbd.escape $),
    modenormal: (modecmd: $ ":", "/", "?" $, modevisual: $ "v", "V" $, modeinsert: $ "i""I""a""A""o""O""c" $),
    modevisual: (modenormal: $ kbd.escape $),
    modeinsert: (modenormal: $ kbd.escape $),
  ))
]

#lorem(50)

```reason
type motion('t) =
  | Enter_mode(motion([> #normal]), 'a) : motion('a)
  | Escape(motion('t)) : motion([> #normal])
```

= User interface

#lorem(20)

#align(center)[
  #cetz.canvas({
    import cetz.draw: *
    let window() = rect((0,0), (6,4))
    let cursor() = rect((0.2,3.8), (0.35,3.45), fill: color.rgb("#000"))
    let modeline() = {
      rect((0.2,0.7), (5.8,1.2))
      content((0.2,0.7), (5.8,1.2), box([buffer-name]), stroke: none)
    }
    let cmdline() = {
      rect((0.2,0.2), (5.8,0.7))
      content((0.2,0.2), (5.8,0.7), box(```:command```))
    }
    window()
    cursor()
    modeline()
    cmdline()
  })
]

where #lorem(30)

= Graphical layering

#lorem(20)

#align(center)[
  #cetz.canvas({
    import cetz.draw: *
    let rat = 3/2
    let ghostdiv() = {
      let pos(y) = ((1,0), (3+1,(3/rat)+y))
      rect((1.8,(3/rat)-0.55), (1.8+0.2,(3/rat)-0.2), fill: color.rgb("#000"))
      content((1.2,(3/rat)-0.55), (1.4,(3/rat)-0.2), fill: color.rgb("#000"), [abc])
      rect(..pos(0))
      content(..pos(-1.7), [ghost div])
    }
    let textarea() = {
      let pos(y) = ((0,0.5), (3,(3/rat)+0.5+y))
      rect((0.8,(3/rat)+0.5-0.55), (0.8, (3/rat)+0.5-0.2))
      content((0.2,(3/rat)+0.5-0.55), (0.2, (3/rat)+0.5-0.2), [abc])
      rect(..pos(0))
      content(..pos(-1.7), [textarea], align: bottom)
    }
    let arrow() = {
      line((2.7, 0.8), (3.8, 0.2), mark: (end: ">"))
    }
    ghostdiv(); arrow(); textarea(); 
  })
]

We utilize what we call _ghost divs_ #fn[also known as _display divs_ in some old code]

_twinning_

= Implementation

#header[The basic editor]. This is our first implementation

#header[The markdown editor].

#header[The vim editor].

// vi: set nowrap:
