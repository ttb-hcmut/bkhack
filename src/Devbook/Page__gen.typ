#import "/article": *
#set cite(style: "alphanumeric")
#set raw(syntaxes: ("reason.sublime-syntax")/* , theme: "quiet.tmTheme" */)
#title[= Staged compilation]
Continuation of BIPHASIC PROGRAMMING

_Off-shoring_, as introduced by Oleg Kiselyov @generating-c, 

= A naive branched sub-compiler
  For example, it's possible to describe CSS stylesheet in Reason in the
same code that defines React components
```reason
let%comptime feed__hint = {
  open At__sh(Shellgen)
  Css_gen.Stylesheet.format1(
    ~className=__name__, {|
    &.command::before { content: ? ;}
    |}, command)
}
```
where the ```reason %comptime``` macro denotes #lorem(10). This can then later be used as
```reason
module Hint {
  [@react.component]
  let make = () =>
    ...
    <span className={
    "command "++feed__hint} />
}
```

Behind the scene

```reason
external feed__hint : string = "src_Page__app_re__feed__hint"
```

#bibliography("works.bib")

// vi: set nowrap:

