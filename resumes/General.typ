#set page(columns: 2)

// wordmarks

//! Based on https://en.wikipedia.org/wiki/Template:TeX_wordmark/style.css
#let latex = {
  set text(font: "New Computer Modern")
  let upper(x) = {
    text(size: 0.75em, baseline: -0.25em, x)
  }
  let lower(x) = {
    text(baseline: 0.25em, x)
  }
  [$"L"#h(-0.26em)#upper("A")#h(-0.15em)"T"#h(-0.1667em)#lower("E")#h(-0.125em)"X"$]
}

//! Based on https://en.wikipedia.org/wiki/Template:TeX_wordmark/style.css
#let bibtex = {
  set text(font: "New Computer Modern")
  [Bibtex]
}

#let typst = {
  text(size: 1em, weight: 600, fill: rgb("#2A2A2A"), font: "Libertinus Serif")[t#h(0em)y#h(0em)p#h(0em)s#h(0em)t]
}

#let ocaml = {
  text(weight: 500, fill: rgb("#444444"), font: "source sans 3")[OCaml]
}

#let typst-language = [Typst]
#let typst-compiler = [Typst]

Currently an undergraduate of computer
science at HCMUT

Work in a group of (3) research friends
(informally and academically in
undergrad projects)
#footnote("https://github.com/ttb-hcmut")
where I organize presentations for
technical trainings

A passionate writer of technical
writing (and creative writing). Write
docs and design notes for community
software and personal software. These
softwares are either my own creations
#footnote("TBA"),
or creations of others, in which case
they can be of different disciplines
and I must closely cooperate with them
to parse their work. Document types
range from simple markdowns to complex
typeset programs e.g. #latex , #typst. For
example, here and here.

#let works-parsers = []

#let works-interpreters = [
  #cite(<utopk-baorepo>)
]

#let works-editor = [
  #cite(<tree-sitter-quarkdown-github>)
]

I can make bespoke tools and
infrastructure (parser of file formats (#works-parsers), interpreters (#works-interpreters), editor integrations (#works-editor), daemons, frontends, etc), have made quite a few
for my school groups
#footnote("TBA") and for my personal
programming space. My tools are often
prototyped in a scripting language, or by being forked / based off
existing tools, then later on getting
their own implementation from scratch
for performance reasons. For example,
Utopk @utopk-baorepo is my own distribution of OCaml
for large-scale scripting, it is my
crown jewel!

This article was written in #typst, compiled by the #typst-compiler compiler. #ocaml is a programming language.

= Skills

#bibliography("works.yml", full: true)
