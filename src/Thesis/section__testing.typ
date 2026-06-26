#import "@preview/tdtr:0.5.5"
#import "@preview/cetz:0.5.2"

= Deployment and testing <testing>

== Deployment <deployment>

We support a diverse selection of deployment platforms. To achieve this, we designed it so that our system, once programmed in terms of source code, can be compiled and bundled with assets to produce bundles of deployment artifacts. The details of these artifacts are discussed in @deployment-artifacts.

=== Deployment artifacts <deployment-artifacts>

The artifacts of our system can be described by @bundles-overview. This can be generated from the `bkhack.bundle` command of our system. Developer of our system can use these bundles to deploy to their service of choice.

- For the front-end bundle, the developer opens a shell in the bundle folder, then run the service-specific deployment command. For Firebase Hosting, it is the `firebase deploy` command.
- For the back-end bundle, the developer opens a shell in the bundle folder, then run the service-specific deployment command. For Fly.io, it is the `fly` or `flyctl` command.

For some services, there are specialized CLI commands to manage deployment e.g. Fly.io, and a configuration file is recommended (as is the case of Render.com) or required (as is the case of Fly.io). This is why each bundle includes optional service-specific configuration files with quality-of-life configurations so that the developer experience is as smooth as possible.

#place(auto, float: true)[
  #figure(caption: [The BKHack system as viewed by deployable artifacts. They are two bundles: the front-end bundle, and the back-end bundle.])[
    #tdtr.tidy-tree-graph([
      - Application
        - Front-end bundle
          - `dist/`
        - Back-end bundle
          - `dcontainer/`
    ])
  ] <bundles-overview>
]

#place(auto, scope: "parent", float: true)[
  #figure(caption: [The front-end bundle of the BKHack system, continued from @bundles-overview.])[
    #tdtr.tidy-tree-graph([
      - Front-end bundle
        - HTML files\
          `index.html`
        - JavaScript files\
          `index.js` 
        - Static assets
          - CSS stylesheet files
          - SVG icon files
        - Service-specific configuration files
          - Firebase `firebase.json`\
            and `.firebaserc` file
    ])
  ] <bundles-frontend>
]

#place(auto, scope: "parent", float: true)[
  #figure(caption: [The back-end bundle of the BKHack system, continued from @bundles-overview.])[
    #tdtr.tidy-tree-graph([
      - Back-end bundle
        - Dockerfile
        - Elixir modules
        - Service-specific configuration files
          - Fly.io `fly.toml` file
    ])
  ] <bundles-backend>
]

== Unit testing <unit-testing>

For our system, there are certain functions and modules that are more complex than the rest.

=== Shell parser <test-sh>

Because we implemented a shell parser instead of reusing external libraries, there is a need to test this parser. Unit tests for the shell parser is implemented in the form of inline tests.

=== Diffing <test-diff>

Because we implemented a diffing algorithm besides reusing ones in the form of external libraries, there is a need to test this algorithm. We've prepared a suite of tests which can be run at anything using the command `dune exec test/diff.exe`.

#place(auto, scope: "parent", float: true)[
  #figure(
    caption: [Result of diff testing],
    table(columns: 2,
      [*Name*], [*Result*],
      ..csv("res_diff.csv").flatten()
    )
  )
]

// == Functional testing - browser user interface testing

// TODO(kinten) storybook

// NOTE(kinten) Chrome, Firefox

// == Service testing

// TODO(kinten) postman
