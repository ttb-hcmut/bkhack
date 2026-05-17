# Reduced motions [^reduced]

The UI components of BKHack exhibits animations such as fading in / out of colors when hover. These animations take a transition duration of 200ms. Animations provide a modern, natural feel to our application. However, due to accessibility reasons, it's not always preferrable to have animations; things should be instantaneously snappy sometimes.

For CSS, all rules that define `transition`-related properties must have their duals when `@media (prefers-reduced-motion)`

> This was motivated when one of the developers (kinten)'s desktop environment (GNOME) uses reduced motion

# Multi-page bundling

Web applications adopt one of these paradigms:

- Multi-page application (MPA)
- Single-page application (SPA)

BKHack adopts a hybrid paradigm. At its core, it's MPA. But within a webpage there can be some "subpages", "subviews", which don't require a request to server to navigate to.

TODO(kinten): insert diagram here

The adoption of this paradigm has been somewhat troublesome. Most build tools support either MPA or SPA, not inbetween. For example, the Webpack bundler accepts a JavaScript entry point and outputs a single main bundle file intended for the entire website: this is SPA; so is the Webpack dev-server. Our build system involves in-house OCaml programming plus some hacking of Webpack: specifically, we spawn multiple Webpack instances to make multiple JS bundles corresponding to each route; and we abandon Webpack dev-server altogether in favor of our custom dev-server built on top of live-server.

# Icon graphics, and how the website renders [^icon]

There are two encodings[^jfp]:

1. The initial encoding. Prefer textual elements
2. The final encoding. Prefer graphical elements

For example, TODO(kinten): insert example graphics here

The final encoding is enabled by the `data-tileset` attribute at the root element. To render the site in its initial encoding form, open the Inspector and unset `data-tileset` to anything other than the value `gui`.

> Our limited build system is what motivated this two-encoding workflow in the first place!

There are various techniques for implementing this two-encoding workflow. At its core is the decoupling of static assets from HTML. Conventionally you would declare assets in HTML or React JSX as img or svg elements. For our workflow, assets are declared in CSS. For CSS rules, you can embed images as background images of elements or pseudo-elements.

# Some notes on bundling and asset management

All static asset - html document, css stylesheet, icon svg - should be separated into files. This is opposite to the inline philosophy e.g. inline styling, css-in-js, etc.

> Inspired by DHH's No Build paradigm. We split / distribute the application into as many file modules as possible, because modern browsers can handle multiple file modules very efficiently (compared to the bundle-based approach)

It'd be nice to have a Reason abstraction for importing static assets. Currently, asset management is manual, requires programmable pipeline, and thus error-prone.

[^jfp]: totally has nothing to do with initial vs. final encoding from theory of algebraic specification

# Style layering

0. CSS reset
1. The initial encoding
2. Reduced-motion encoding (see [^reduced])
3. The final (graphical) encoding (see [^icon])
4. The light mode encoding
5. ( syntax highlighting for some text )
6. Language encoding (see Language layering)
7. Keyboard encoding
8. CSS User-agent (Arc themes, GNOME Web Custom JS/CSS, Tampermonkey extension for Chrome and Firefox)

This architecture was formed based on what we want, plus that we have the right setups to quickly test and report for these layers.

- Layer 2 is usually reported by Kinten (his GNOME machine uses reduced motion and he explicitly requested this feature)
- Layer 4 duty. Due to their respective daily driver setups, Kinten usually reports for light mode, Khang usually reports for dark mode.
- Layer 8 duty. Due to their respective daily driver setups, Kinten usually reports for GNOME Web, Khang usually reports for Chrome, Tuong usually reports for Arc.

Some encodings are not simply style, but also behavior as well. e.g. Language encoding, Keyboard encoding.

```reason
module App' = Decorator.(
    val (module App)
    ->React.use(module Tileset.Make)
    ->React.use(module Language.Make)
    ->React.use(module Keyboard.Make)
)
```

# Language layering

Not to be confused with internalization, or i18n. Language layering is a generalization, an umbrella term for activities related to implementing internalization (write once, will be available across languages) and localization (adapt something per language, supporting multiple languages) etc.

0. English encoding
1. Vietnamese encoding

For a string $s$, if $s$ doesn't have a corresponding translation in the current language, it will fallback to the string $s_0$ that is the English encoding (layer 0).

- Layer 1 duty. Due to their respective daily driver setup, Kinten usually reports for the Vietnamese language.

Currently, language layering is implemented in CSS styles, in similar fashion with Style Layering. In practice, most language layering is implemented via an i18n system as part of the build system, which will support an arbitrary number of languages, and there will be a centralized dictionary-like / index-like mechanism for writing and using translations. It will be a generic system. For now, the authors do not feel the need to use or build such a system.

# Build system and file attributes

For our current build system, our philosophy is to distribute configurations as much as possible. Avoid the phenomenon where we need a bunch of centralized `.rc` files or `jsconfig` files or a dictionary in a script file, etc.

We need to inform the build system that for a Reason page file $x$ there is a mapping to a JavaScript bundle $y$ at a url $y'$. In early versions, I (kinten) tested using a dictionary placed in the script file to define this mapping. In newer versions, I have decided to utilized Reason's infile floating attributes [^attributes] in each Reason page file. This is a native way to provide decorator-like metadata to a file / module unit.

```reason
[@Bkhack.page "/item"]
// rest of file
```

[^attributes]: https://ocaml.org/manual/5.3/attributes.html

> One of the most definitive use cases of floating attributes! The OCamldoc system also support floating attributes for manipulating system.

# Diverse implementation

For every module, we have alternative modules that achieve a similar goal using different methods, different algorithms. The idea is that diverse implementations of a shared goal provide benchmarking comparisons and fallbacks when one implementation breaks for whatever reason. This applies for module and extends to service as well, as in our Service-oriented Architecture. A list of some of these (we haven't kept track of all):

- For parsing the bkhack shell language, we use two implementations, one based on parser combinators (src/Shell__parse.re) and one based on ocaml re (src/Shell__parse_1.re). Refer to [streaming](./streaming.pdf) for a full technical report on this, and [parsing](./parsing.pdf) for a comparison between parsing techniques.
- For parsing of the markdown language - as used throughout the project including the article view and pull request view and editor view etc - we use two implementations, one based on Daniel Bünzli's Cmarkit library, one based on Remark. See [markdown](./markdown.pdf) for the full technical report.
- For database, we use six implementations.
- For Firebase, we use two implementations, one is the `@firebase` Node libraries (modular API) provided by Google, and one based on RESTful API at the URL `https://firestore.googleapis.com`.

A telling case study of this is the markdown module. We initially used CMarkit. However, CMarkit being originally written for OCaml, when ported to Reason we hit a rare bug in the Melange compiler which is that extensible types with conflictive name with a module will result in the module members being overridden when the code is compiled to JavaScript; that, and another bug where Melange doesn't fully support OCaml's Object API (Object, as in the internal low-level value presentation API). While we can switch to using a different library, we liked Cmarkit's declarative markdown syntax tree API. We decided to use this API as a "front-end", a basis for our markdown abstraction, and under which we use another library that is Remark (with Rehype for converting to HTML) from the JavaScript ecosystem. This new abstraction we call Remarkit. All the while, we still hold onto the goal to one day "fix" all the rare bugs in Melange to finally be able to use the original Cmarkit library.
