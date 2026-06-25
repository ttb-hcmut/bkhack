
= Realization <realization>

// NOTE(kinten) development = implementation + documentation + the working experience

== Technologies

=== Front-end

// NOTE(kinten) limit to FOUR final contenders for readability

// TODOne(hgt+khang) please proofread to make sure you understand without knowing absolutely anything about UI programming

For languages and frameworks, there are metric - certain attractive features that make the language more robust and pleasant to develop web UI applications. We have developed a collection of metrics which are:

- Whether or not the technology supports inline writing of HTML or HTML-like markup or other forms of markup.
- How strict is the type system and its programming experience. Static type-checking is preferable.
- How well supported documentation facilities. This is mentioned as a design goal in @design-goals, we want great maintainability.
- Does it come with an opinionated programming paradigm? Today there are many programming paradigms, such as object-oriented programming, functional programming, procedural programming, etc. 
- Continuation of the above point: does it come with an opinionated UI programming paradigm? Today there are many UI programming paradigms, such as reactive programming @reactive-programming, the Elm Architecture @elm-architecture, immediate-mode graphics rendering @immediate-mode. These programming models specialize in the domain of UI programming and will help us build safer systems by naturally leaning developers towards intuitive mental models during programming.

#figure(caption: [In clockwise order from top-left: logo for the OCaml programming language; logo for the Reason programming language; logo for the Reason React binding; logo for the React library])[
  #box[#image("assets/ocaml__colour-logo.svg", width: 4cm,)]
  #h(16pt)
  #box[#image("assets/Reason-logo.svg", width: 4cm)]
  #box()[
    #box(radius: 0.5em, clip: true)[#image("assets/ReasonReact-logo-raster.png", width: 8cm)]
    #v(16pt)
  ]
  #box(radius: 0.5em, clip: true)[#image("assets/React-logo-raster.png", width: 3cm)]
]

Reason @reason (formerly ReasonML) is a functional programming language. It belongs in the language family of ML, specifically as a direct descendent of OCaml @ocaml, a formally-proven industrial-strength functional programming language with a robust module system.

Most importantly, Reason has first-class interop binding with the React library @reactjs, a popular system for writing UI in the reactive programming pattern. The interop, called Reason React @reason-react, leverages Reason's strong functional features such as algebraic data types, exhaustive pattern matching, a module system as inherited from OCaml for code organization and transformation, combined with React's mature reactivity system, and a natural foreign-function interface (FFI) layer so that Reason can interact with JavaScript and thus React.

#figure(caption: [From left to right: logo for the Haskell programming language; logo for the Elm programming language])[
  #box[#image("assets/Haskell-Logo.svg", width: 2.3cm)]
  #h(8pt)
  #box[
    #image("assets/elm-logo-raster.png", width: 2cm)
    #v(-4pt)
  ]
]

Elm @elm is a pure functional programming language. It belongs in the language family of Haskell @haskell. Elm is known for pushing for a unique opinionated UI programming model called the The Elm Architecture, or TEA @tea. Elm also benefits from its Haskell heritage where there is a separation between pure function evaluation and monadic evaluations that can have side effects, thus a formalized way for programmers to track what their programs can and cannot do.

#figure(caption: [])[
  #table(
    columns: (auto, 1fr, 1fr, 1fr, 1fr),
    table.header(
      [], [*JavaScript\ with ReactJS*], [*OCaml\ with Bonsai*], [*Reason*], [*Elm*]
    ),
    [*Prog. paradigms*], 
    [Object-oriented\ \ Functional-ish\ Imperative],
    [Object-oriented-ish\ Functional],
    [Object-oriented-ish\ Functional],
    [Functional],
    [*UI paradigms*],
    [FRP],
    [FRP],
    [FRP],
    [TEA],
    [*Inline markup*],
    [Native (JSX)],
    [Non-native (PPX)],
    [Native (JSX-like)],
    [None],
    [*Documentating*],
    [JSDoc], [`.mli` files], [`.rei` files], [Elm Doc. Format],
    [*Type-checking*],
    [Dynamic],
    [Static],
    [Static],
    [Static],
  )
]

In general, most languages and frameworks in this comparison provide some sorts of inline mark-up writing. 

Similarly, all languages encourage documentation through their own textual formats. In particular, OCaml and Reason sport their own system of self-documenting signature files, where a supposedly header file for machine to parse as API also serves as documentation for humans to read

Regarding type-checking, JavaScript is the only language which doesn't fit all criteria due to being dynamically typed by default.

Combined these with personal experience from the development team of this project BKHack, it was decided that Reason is the language for front-end UI development.

=== Front-end hosting

// NOTE(kinten) static site hosting

For our system, the front-end is a static-site web application i.e. browser requests at a route and always deterministically receives a HTML+JS+CSS bundle. This is contrary to dynamic web applications e.g. web apps traditionally powered by technologies like PHP, where the server is non-trivially program to handle requests at each route. The static-site pattern greatly reduces development complexity for little runtime cost (insofar as non-functional requirements of our system are concerned).

#figure(caption: [firebase.google.com])[
  #image("assets/firebase_logo.png", width: 4cm)
]

// Firebase @firebase is. Firebase Hosting @firebase-hosting is.

#figure(caption: [netlify.com])[
  #image("assets/netlify-logo.png", width: 4cm)
]

// Netlify @netlify is.

/*

=== Back-end

#table(
  columns: (auto, 1fr, 1fr, 1fr, 1fr),
  table.header(
    [], [*Python*], [*Elixir*], [*OCaml\ with Dream*], [*Haskell\ with Yelp*]
  ),
  [Built-in resilience]
)

=== Back-end hosting

#figure(caption: [render.com])[
  #image("assets/logo-render.png", width: 4cm)
]

#figure(caption: [cloud.google.com])[
  #image("assets/logo-google_cloud.png", width: 6cm)
]

/*
=== Fullstack

#table(
  columns: (auto, 1fr, 1fr, 1fr, 1fr),
  table.header(
    [], [*Ruby on Rails*], [*OCaml\ with Bonsai + Dream*], [*OCaml\ with Eliom*], [*Elixir\ with Phoenix*]
  )
)

=== Database

#table(
  columns: (auto, 1fr, 1fr),
  table.header(
    [], [*Firebase*], [*MongoDB*]
  )
)

*/

/*

=== UI prototyping and documentation

#table(
  columns: (auto, 1fr, 1fr),
  table.header(
    [], [*Figma*], [*Penpot*]
  )
)

*/

*/

=== Conclusion <technologies-final>

OCaml and Reason and their ecosystem of languages and frameworks are known to facilitate documentation which is what we want. This will become relevant in @documentation-rituals. Reason's support for functional programming and reactive programming through React interop also proves itself to be an attractive choice. That's why we've chosen Reason as the primary programming for developing BKHack's front-end.

// - Storybook
// - Postman
// - Mermaid and PlantUML

== Design system 

// TODO(kinten+hgt) why do we need a design system? its a framework of reusable components so that we don't need design skills to use, or need to design from scratch

// TODO(kinten+hgt) an interactive version of this design system is available through this project's storybook, talk more in appendix?

// TODO(kinten+hgt) images for related design systems? logo + set of sample of components

While established design systems like Material Design
@material-design, Ant Design @ant-design, Apple Human Interface  @apple-hig, and GNOME HIG @gnome-hig provide comprehensive frameworks for general-purpose applications, they prioritize consumer-friendly aesthetics and mobile-first approaches that conflict with our target audience's needs. These systems emphasize visual polish through shadows, animations, and generous whitespace—patterns designed for casual users navigating touch interfaces.

As stated previously in @prototype, our technical audience expects the efficiency and information density of developer tools. We determined that adapting an existing consumer-oriented system would require removing more features than we retain, effectively fighting against the design language rather than leveraging it. Therefore, we introduce *the BKHack design system* as a purpose-built collection of rules and reusable components tailored specifically for academic knowledge workers who value functional density over popular aesthetics.
#footnote[Disclaimer: The following subsections outline the visual and structural highlights of the BKHack design system. The full technical specification is maintained in a separate file, serving as the primary reference for implementation alignment, accessibility compliance, and semantic token mapping]

Through multiple iterations, we adopted a terminal-UI aesthetic, and as such, the BKHack design system establishes a cohesive foundation that bridges the gap between a modern web application and the functional directness of terminal-UI (TUI) applications.

=== Visual hierarchy

Through experimentation, we initially adopted a skeuomorphic design pattern, not too dissimilar to existing platforms like reddit.

Skeuomorphic design #footnote("https://www.interaction-design.org/literature/topics/skeuomorphism") #footnote("https://en.wikipedia.org/wiki/Skeuomorph#Arguments_in_favor") is a commonly-used UI style and was quite popular in the 2000s. Skeuomorphic design patterns are, for example: drop shadows, gradients, and pseudo-3D effects; originated in an era when digital interfaces needed to mimic physical objects to aid user understanding. For our technical audience, these affordances are not only unnecessary but actively counterproductive. Shadows consume visual bandwidth without conveying information, gradients introduce color variations that compete with semantic signals, and depth effects conflict with the flat, high-contrast environments (IDEs, terminals, documentation sites) our users inhabit daily.
// TODO(hgt, paragraph flow not logical, talking points are repeated without meaningful impact)
By rejecting skeuomorphism in favor of a flat, surface-layered hierarchy, we achieve several goals: first, we reduce visual noise, allowing content and structure to dominate the interface; second, we increase information density by eliminating decorative padding and effects; third, we create a cohesive aesthetic language that feels native to the development environment rather than borrowed from consumer applications.

To avoid "skeuomorphic" shadows and maintain a flat, technical aesthetic, we implemented hierarchy through surface layering. This system utilizes three distinct tiers:
- The Base (main page background)
- The Mantle (primary containers like cards and navigation)
- The Crust (inputs and insets), which creates an illusion of depth for interactive fields.

We implemented a CLI-inspired header motif for page navigation, such as displaying

```sh
$ git pr --list | grep open
```
// TODO(hgt) placeholder, subject to change in the future

which provides both a literal command-like path and high-level metrics for the current view (e.g., "5 open pull requests"). This motif serves two purposes: it rewards users familiar with terminal commands by providing recognizable syntax, and it subtly incentivizes less experienced users to explore command-line tools by presenting them in a non-threatening reading context.
#figure(  
  image("assets/bruhhack/header.png"),
  caption: "The header of discussions in BKHack"
)

=== Color palette and semantic meanings

A primary challenge was achieving a visual hierarchy that accommodates high density without causing visual fatigue.

We decided against aggressive color variations in favor of the Catppuccin pastel palette, using the "Mocha" and "Latte" variants to ensure eye strain is reduced during extended use while maintaining dual-theme parity with identical contrast ratios. To reconcile our university identity with this aesthetic, we integrated HCMUT-brand blue (\#1488DB) as the primary action color across both themes. We enforced a strict rule that color is never used for mere decoration; instead, it carries consistent semantic meaning:
- Green for success/verification
- Red for danger/destruction
- Mauve for modifications or in-progress states.
#grid(
  columns: 2,
  rows: 2,
  column-gutter: 1cm,
  row-gutter: 1cm,
)[
#figure(
  image("assets/1544x1544_circle.png", width: 3cm),
  caption: "The logo of catppuccin"
)][
#figure(
  image("templates/bachkhoa-style/hcmut.png",width: 3cm),
  caption: "The logo of HCMUT"
)][
#figure(
  image("assets/bruhhack/latte.svg", width: 4cm),
  caption: "Catppuccin latte theme"
)][
#figure(
  image("assets/bruhhack/mocha.svg", width: 4cm),
  caption: "Catppuccin mocha theme"
)
]
This semantic consistency is critical for our multi-faceted navigation; it ensures that as a user moves between different tabs (e.g., from an Article to an Issue), they do not have to re-learn button functions and can instead rely on muscle memory.

We further implemented a separation of tab signature colors from semantic action colors - while specific sections like "Issues" may have distinct red-adjacent pastel signatures for identification, primary actions within those sections remain "Brand Blue" to prevent users from mistaking a "New Issue" button for a destructive action.

Feedback is provided through status badges using a "redundant encoding" approach, combining color, icons, and text so that "power users" can recognize the state of a post—such as whether it is verified or outdated at a single glance.

=== Use of typeface

To reinforce the platform's CS-centric identity, we adopted a two-typefaced system that serves as a structural signifier.

While sans-serif is used for long-form prose to maintain readability, monospaced fonts are strictly applied to headings, timestamps, and metadata labels. This visually distinguishes content from syntax and makes the platform feel like an extension of the developer's local environment.

#figure(  
  image("assets/bruhhack/BKHackIssues.jpg"),
  caption: "The post issues page of BKHack"
)

=== Motion and animation <motion>

To maintain the platform's directness and respect user preferences, we adhere to a minimal-motion philosophy. All transitions are restricted to essential state changes such as: hover effects (opacity/color shifts ≤200ms), focus indicators, and page transitions. Avoiding decorative animations like slides, bounces, or parallax effects.

This serves in improving perceived performance by eliminating animation delays; it respects users with vestibular disorders or motion sensitivity (consistent with WCAG 2.1 success criterion 2.3.3); and it maintains consistency with the immediate feedback paradigm of terminal applications. The system automatically respects the `prefers-reduced-motion` media query, disabling even essential transitions for users who request it at the OS level.

=== Visual vocabulary and text-based graphics <multigraphics>

Rather than relying on custom illustrations or icon-heavy navigation, we prioritize text-based visual elements but not entirely omitting icons. Status indicators combine text labels, icons, and color in a redundant encoding pattern, ensuring accessibility while allowing power users to scan states at a glance (e.g., a "Verified" badge shows green color + checkmark icon + "Verified" label simultaneously).

By taking a text-first approach it reduces dependency on visual assets, improves accessibility for screen readers and high-contrast modes.

// TODO(hgt) if text is first-class citizen, what is second-class citizen? how should we treat them? because currently we actually show graphical icons first

== Documentation rituals <documentation-rituals>

During this project, every member of the development team is encouraged to document their work and share their ideas as much as possible. We believe it is a way to boost morale and bolster communication.

Write manuals / guides MD files for developers on how to get certain things done. Can be opened and read publicly. Write MDX files. Can be opened with Storybook.

Record design decisions.

Write interface files. Follow the official ocaml guide @ocaml-doc-guide.
- Write documentation in .mli files
- Write introductory documentation for the toplevel module
- Organize signatures into logical sections
- Document all your signatures
- Put documentation comments after signature elements
- Write usage examples
- Properly document deprecations
- Have meaningful README

== Layering of styles

We consider it in development time and also in run time that styles should be implemented in a specific order. This order is so that we can achieve the ideas presented in @motion and @multigraphics.

#figure(
  align(image("assets/diagrams/UML-style_layering.svg"),center),
  caption:[The ordered layers of styling]
)

== Bundling of front-end

Web applications adopt one of these paradigms:

- Multi-page application (MPA)
- Single-page application (SPA)

BKHack adopts a hybrid paradigm. At its core, it's MPA. But within a webpage there can be some "subpages", "subviews", which don't require a request to server to navigate to.

All static asset - html document, css stylesheet, icon svg - should be separated into files. This is opposite to the inline philosophy e.g. inline styling, css-in-js, etc.

== Source code

The implementation source code can be found at

#align(center)[
  #let bkhack-repo = "https://github.com/ttb-hcmut/bkhack"
  #link(bkhack-repo, bkhack-repo)
]

which is hosted on the GitHub platform, and where there will be a detailed documentation greeting file (a.k.a. a `README.md` file) to provide quick guide for internal developer users who may use our system as foundation to extend with more pages and services. @bkhack-repo-usage shows a section in this `README.md`.

#place(auto, float: true)[
  #figure(
    image("assets/bkhack-repo-usage.png"),
    caption: [A section of the front page of the source code repository of the bkhack system as seen on github.com. We provide an installation flow where BKHack (here writen as bkhack) is easily usable as an OCaml / Reason library through a few short OPAM installation commands. Source: window capture at https://github.com/ttb-hcmut/bkhack]
  ) <bkhack-repo-usage>
]
