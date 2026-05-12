// TODO(hgt) https://calculist.blogspot.com/2005/04/balance-of-expressiveness-and.html integrate this into design goals?
// TODO(kinten+khang) reorganize asset files
// TODO(kinten+hgt) https://fsharpforfunandprofit.com/posts/concurrency-reactive/  reference date warning
// TODO(kinten+hgt) use this https://firebase.google.com/products/data-connect
// TODO(kinten) custom dialog input components

#import "templates/kinten-style/main.typ": *
#set text(lang: "VN")
#import "@preview/cetz:0.4.2"

#show: doc
#show table.cell.where(y: 0): set text(weight: "bold")

#let single_page(f) = {
  f(); pagebreak()
}

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

#single_page(outline)

#single_page(
  outline.with(
    title: "Figures",
    target: figure
  )
)

#set heading(numbering: "1.")

// Header and footer
#set page(
  footer: context [
    #place(line(start:(0%,-10%),end:(100%,-10%)))
    Capstone project report
    #h(1fr)
    Page #counter(page).display("1/1",both:true)
],
  header: context[
    #place(
      image("templates/bachkhoa-style/hcmut.png",height:50%),
      bottom + left,
    )
    #place(
      [Ho Chi Minh City University of Technology\ 
      Faculty of Computer Science and Engineering],
      bottom + left, dx: 6.5%,
    )
    #place(
    line(start:(0%,0%),end:(100%,0%)),
      bottom + left, dy:10%,
    )
  ]
)

#include "section__overview.typ"
#include "section__analysis.typ"
#include "section__design.typ"
#include "section__foundation.typ"
#include "section__realization.typ"
#include "section__timeline.typ"
#include "section__testing.typ"
#include "section__conclusion.typ"
#bibliography("bibliography.yml", full:true)

#pagebreak()

// TODOne(kinten+khang): appendix subsections should use alphabetical numbering

//this works.. but why????
#show heading.where(level: 1): set heading(numbering: none)
#set heading(numbering: (first,..nums) => numbering("A.",..nums))
#counter(heading).update(0)

= Appendix

== Logo

#figure(  
  image("assets/bkhack-logo-withbg.png", width: 5cm),
  caption: "The logo of BKHack"
)

The BKHack logo is explicitly grounded in the official visual identity of Ho Chi Minh City University of Technology (HCMUT), and its design choices closely follow the university’s brand recognition principles while extending them to fit its own philosophy.

According to HCMUT’s brand documentation#footnote("https://hcmut.edu.vn/gioi-thieu/nhan-dien-thuong-hieu"), the university logo is conceived as a three-dimensional spatial form, centered on a regular hexagon inscribed within a circle. Its structure is inspired by honeycomb architecture, a form regarded as both simple and scientific. This geometry symbolically represents diligence, solidity, and creativity—values strongly associated with HCMUT’s academic culture. The color system is built from two shades of blue, conveying calmness, rigor, and formality.

BKHack preserves this conceptual foundation. The hexagonal outline remains the dominant structural element, maintaining immediate visual continuity with the HCMUT logo. Rather than treating the hexagon as a mere container, the BKHack logo integrates it directly with the “BK” letterform. The outline and the letters visually interlock, making the boundary of the logo feel structural rather than decorative. This blending mirrors software concepts where interfaces, abstractions, and implementations are tightly coupled, reinforcing the idea that BKHack is an internal, purpose-built system rather than an external add-on.

In contrast to the strictly institutional palette, the inclusion of orange in the “Hack” portion of the logotype introduces a deliberate deviation. This color choice serves as a subtle nod to Hacker News, a well-known social news platform within the global computer science and software engineering community.

Taken together, the BKHack logo inherits HCMUT’s geometric rigor, symbolism, and color discipline that is recognizably related to the university, yet clearly positioned as a distinct platform.
#pagebreak()

/*

= Colophon

This report was programmed in the Typst language and compiled using the Typst compiler.

*/

