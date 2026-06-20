#let header = text.with(weight: 700)
#show heading.where(level: 1): set heading(numbering: none)
#set heading(numbering: (first,..nums) => numbering("A.",..nums))
#counter(heading).update(0)

= Appendix

== Logo

#grid(
  columns: 2,
  column-gutter: 1cm,
  row-gutter: 1cm,
)[
#figure(
  image("assets/bkhack-logo-withbg.png", height: 3cm),
  caption: "The full logo of BKHack"
)][
#figure(
  image("assets/logo.svg", height: 3cm),
  caption: "The compact logo of BKHack"
)
]

The BKHack logo is explicitly grounded in the official visual identity of Ho Chi Minh City University of Technology (HCMUT), and its design choices closely follow the university’s brand recognition principles while extending them to fit its own philosophy.

According to HCMUT’s brand documentation#footnote("https://hcmut.edu.vn/gioi-thieu/nhan-dien-thuong-hieu"), the university logo is conceived as a three-dimensional spatial form, centered on a regular hexagon inscribed within a circle. Its structure is inspired by honeycomb architecture, a form regarded as both simple and scientific. This geometry symbolically represents diligence, solidity, and creativity—values strongly associated with HCMUT’s academic culture. The color system is built from two shades of blue, conveying calmness, rigor, and formality.

BKHack preserves this conceptual foundation. The hexagonal outline remains the dominant structural element, maintaining immediate visual continuity with the HCMUT logo. Rather than treating the hexagon as a mere container, the BKHack logo integrates it directly with the “BK” letterform. The outline and the letters visually interlock, making the boundary of the logo feel structural rather than decorative. This blending mirrors software concepts where interfaces, abstractions, and implementations are tightly coupled, reinforcing the idea that BKHack is an internal, purpose-built system rather than an external add-on.

In contrast to the strictly institutional palette, the inclusion of orange in the “Hack” portion of the logotype introduces a deliberate deviation. This color choice serves as a subtle nod to Hacker News, a well-known social news platform within the global computer science and software engineering community.

Taken together, the BKHack logo inherits HCMUT’s geometric rigor, symbolism, and color discipline that is recognizably related to the university, yet clearly positioned as a distinct platform.
#pagebreak()

// == An architecture of modules

== Programming language parsing <parsing>

// Based on @giao-trinh-trinh-bien-dich. #lorem(50)

#header[Markdown.] For the writing experience of our website, we've used and tests a collection of publicly-available markdown parsers in both the JavaScript ecosystem and the Reason / OCaml ecosystem.

#header[Shell language.] For the command bar of our website, we've developed a robust command language based on the Shell Command Language @opengroups-shell. A more detailed discussion can be found in our developer handbook at @devbook-streaming.

// == Diffing algorithms <diffing-algo>

// Myers. @myers-diff #lorem(50) A more detailed discussion can be found in our developer handbook at @devbook-diff.