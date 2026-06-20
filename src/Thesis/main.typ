// TODO(hgt) https://calculist.blogspot.com/2005/04/balance-of-expressiveness-and.html integrate this into design goals?
// TODO(kinten+khang) reorganize asset files
// TODO(kinten+hgt) https://fsharpforfunandprofit.com/posts/concurrency-reactive/  reference date warning
// TODO(kinten+hgt) use this https://firebase.google.com/products/data-connect
// TODO(kinten) custom dialog input components

#let style = {
  // NOTE(kinten) swap between
  // - "bachkhoa-style"
  // - "kinten-style"
  "bachkhoa-style"
}

#import ("templates/"+style+"/main.typ"): *
// #import "templates/kinten-style/main.typ": *
#set text(lang: "VN")
#import "@preview/cetz:0.4.2"

#show: doc
#show table.cell.where(y: 0): set text(weight: "bold")

#let single_page(f) = {
  f(); pagebreak()
}

#single_page(() => [
  Warning: the content is WIP and is not representative of final work
])
 
#cover(
  [Develop a social news website oriented towards Computer Science for HCMUT],
  [BKHack: A Computer Science Social News Website for HCMUT],
)

= Abstract

We present *BKHack*, a social news website oriented towards computer science, designed for internal use at Bach Khoa University of Ho Chi Minh City. The platform provides a centralized space for students to share knowledge, discuss research topics, and stay up-to-date with developments in the field.

Throughout this report, we mainly discuss the analysis, the design and several implementation details of BKHack. The analysis involves user-level specifications of features and also non-functional requirements that will help us achieve feature goals. The design includes high-level architectural diagrams and other developer-oriented specifications. The "implementation" section involves intiial implementations of ideas presented in the design section. We also provide a timeline which should realistic map our development projection for the next phase of this project.

In conclusion, we've gone through the initial development phase of this project with a working prototype based on this report.

#pagebreak()

= Guanrantee of originality

This capstone project is an original work of our group under the supervision of Mr. Trương Tuấn Anh. All content in this capstone are entirely of our own and free from plagiarism.

The tables and figures in this paper were collected from various sources. These sources are cited in the "References" section or footnoted directly within the page.

Were any form of academic misconduct to be detected, we as the BKHack developers shall take full responsibility. Ho Chi Minh City University of Technology (HCMUT) shall bear no liability for any copyright or intellectual property infringements committed by us during this project.

#signing[The BKHack developers]

#pagebreak()

= Acknowledgements

We would like to express our gratitude to the Hồ Chí Minh University of Technology (HCMUT) for providing us with opportunities to study, practice, connect; to attain the necessary knowledge and skills to implement this project.

We are indebted to Mr. Trương Tuấn Anh, Mr. Nguyễn Minh Tâm, and other advisors of the Faculty of Computer Science and Engineering for providing feedback and guidance for this software engineering project.

Due to our limited experience and knowledge, some shortcomings are unavoidable. We sincerely look forward to receiving comments and advice from our reviewers.

#signing[The BKHack developers]

#v(1.6em)

To Tùng, our mutual friend, who originally proposed the concept for this project, a warm and sensible person who gave feedback on ideas, warned and encouraged us on the way.

#signing[Tường and Bảo]

#v(1.6em)

To Triết, the smart and kind brother I don't deserve, who encouraged me throughout this journey.

#signing[Bảo]

#pagebreak()

#let outline1() = {
  outline(depth: 2)
}

#single_page(outline1)

#single_page(
  outline.with(
    title: "Figures",
    target: figure
  )
)

#show: with_header

#include "section__overview.typ"
#include "section__analysis.typ"
#include "section__design.typ"
#include "section__foundation.typ"
#include "section__realization.typ"
// #include "section__timeline.typ"
#include "section__testing.typ"
#include "section__conclusion.typ"
#bibliography("bibliography.yml", full:true)
#pagebreak()
#include "section__appendix.typ"

// TODOne(kinten+khang): appendix subsections should use alphabetical numbering

//this works.. but why????
/*

= Colophon

This report was programmed in the Typst language and compiled using the Typst compiler.

*/

