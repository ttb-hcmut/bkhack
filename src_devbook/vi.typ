#import "/article": *
#import "./kbd.typ"
#import "@preview/finite:0.5.1": automaton
#set raw(syntaxes: ("reason.sublime-syntax")/* , theme: "quiet.tmTheme" */)
#title[= Vim motion]

#lorem(50)

#align(center)[
  #let layout = (
    modecmd: (0, 2),
    modenormal: (0, 0),
    modevisual: (2, 0),
    modeinsert: (0, -2)
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
    modenormal-modecmd: (angle: 0deg, dist: 9pt)
  )
  #automaton(layout: layout, labels: labels, style: style, (
    modecmd: none,
    modenormal: (modecmd: $ kbd.tab, kbd.tab $),
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

// vi: set nowrap:
