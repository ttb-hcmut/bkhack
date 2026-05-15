#import "/article": *
#import "./shell__parse.typ"
#import "./shell__sym.typ"
#let (bkhack, Bkhack) = ([bkhack], [bkhack])
#title[= Stream-based programming, as compared to sh]
For #bkhack, the user gets to familiarize with the concept of _stream-based
programming_. Indeed, visitors of the site will often catch glance of
command hints and tips as they are littered about the user interface.
#lorem(20)\
  Stream programming in #bkhack is sh pipelining @shlang, with certain flavorful
differences. The most important difference is that, instead of dealing
with textual data and lines and files, here we deal with abstract post
data and post counts. Consider
#align(center)[```sh feed | split -c 10 ```]
where ```sh split``` has the option ```sh -c NUM``` where `NUM` is the
count size of each chunk. Conventionally, the POSIX ```sh split``` command
accepts the option ```sh -l NUM``` where `NUM` is line number size of chunk
.\
  Another difference is that there is no filesystem, no concept of space
. There is a command for every page, but there's no way to navigate
"relatively" such as going "back" or "forth"; in other words, there's
no ```sh cd``` command.\
== Shell and kernel
The original sh language is a user interface for the system shell, which
itself is an interface for the kernel, as part of the shell-kernel
architecture @shell-kernel-arch. In comparison, the #bkhack shell
language is highly abstract and doesn't need a stand-in kernel analogy:
at most, the #bkhack website's command system emulates the shell-kernel 
architecture.
== Pipeline
Introduced by Doughlas, pipelining enables commands to compose with each
other parsibly simply via textual data. In this composition, there are
relationships between commands to form the pipeline by parts.\
  The _source_ is the start of the pipeline, it exclusively produces
output. The _sink_ is the end of the pipeline, it exclusively consumes
the input. #lorem(40) The rest are _cantrips_--commands that don't produce
output but instead apply an effect onto the current environment.\
  It's worth noting that, even on the conceptual level, the evaluation
order of the part commands is that all commands start simultaneously when
a pipeline runs.\
  For the #bkhack shell language, pipelining is first-class citizen.
The grammar expects all commands to unequivocally form a pipeline, as
evident by @gr, and multiple groups of commands will connect to form
branching pipelines.
== Function <fn>
A reusable pipeline or grouping of commands would be called a _function_
. In the #bkhack shell language, #lorem(70)\
#lorem(70)
== Grammar
The grammar of the #bkhack shell language, given in EBNF form in @gr, #lorem(30)
Notice how the command rule do not distinguish parts into flags or values
which are expected from most real-world usage. Indeed, the responsibility
of interpreting these parts, a.k.a. _options_, is left to the higher-level
_option parser_, such as POSIX `getopts`.
#place(auto, float: true, scope: "parent")[
  #figure(caption: [Grammar for the #bkhack shell language], shell__parse.langchain) <gr>
]
== Typing
The typing of the #bkhack shell language, given in @typ, #lorem(30)
This is useful when shell commands have to be embedded in a statically-typed
programming language.
#place(auto, float: true, scope: "parent")[
  #figure(caption: [Typing for the #bkhack shell language], shell__sym.v) <typ>
]
== Reference
#bibliography(title: none, "./works.bib")
