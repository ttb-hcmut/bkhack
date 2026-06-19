#import "/article": *
#import "@preview/tdtr:0.5.5"
#import "vocab.typ" as o
#import "./shell-parse.typ"
#import "./shell-sym.typ"
#import "@local/diagramming:0.1.0": kbd
#title[= Stream-based programming, as compared to sh]
#set heading(numbering: none,  outlined: true, supplement: [#text(weight: 900, fill: rgb("#3851A4"))[§]#h(-0.4em)])
#set cite(style: "alphanumeric")
#show heading: it => {
  if it.level == 3 {
    set text(size: 0.9em); it
  } else { it }
}
// #show cite: it => text(fill: rgb("#3851A4"), it)
For #o.bkhack, the user gets to familiarize with the concept of _stream-based
programming_. Indeed, visitors of the site will often catch glance of
command hints and tips as they are littered about the user interface.
#lorem(20)\
  Stream programming in #o.bkhack is sh pipelining @shlang, with certain flavorful
differences #fn["flavorful" here means that the differences are poignant ones that the language writer feels when she transitions between the languages. See more at XXX]. The most important difference is that, instead of dealing
with textual data and lines and files, here we deal with abstract post
data and post counts. Consider
#align(center)[```sh feed | split -c 10 ```]
where ```sh split``` has the option ```sh -c NUM``` where `NUM` is the
count size of each chunk. Conventionally, the POSIX ```sh split``` command
accepts the option ```sh -l NUM``` where `NUM` is line number size of chunk
.\
  Another difference is that there is no filesystem, no concept of "space"
. There is a command for every page, but there's no way to navigate
"relatively" such as going "back" or "forth"; in other words, there's
no ```sh cd``` command.\
  #lorem(50)\
  #lorem(50)\
  #lorem(50)
== Semantics
The original sh language is a user interface for the system shell, which
itself is an interface for the kernel, as part of the shell-kernel
architecture @shell-kernel-arch. In comparison, the #o.bkhack-shell
language is highly abstract and doesn't need a stand-in kernel analogy:
at most, the #o.bkhack website's command system attempts to emulate the
shell-kernel architecture, so that the user feels the shell-kernel
architecture even when it's not really there.\
  #lorem(50)
== Session
A shell is usually seen as a session that has REPL behavior, an environment with its own variables, and shells can stack on top of one another and can be "popped".\
  For #o.bkhack, #lorem(30)
== Stream programming
Stream-based programming involves #lorem(30)\
  #lorem(50)\
  #lorem(50)\
  #lorem(50)
== Composition via pipeline
Introduced by Douglas McIlroy, pipelining enables commands to compose
with each other parsibly simply via textual data. In this composition
, there are relationships between commands to form the pipeline by parts
. This composition is part of the design patterns in designing Unix
programs as a whole @taoup-design-patterns.\
#let ls-sources = [```sh ls```, ```sh cat```, etc]
#let ls-filters = [```sh grep```, ```sh sort```, ```sh split```, ```sh cut```, etc]
#let ls-cantrips = [`mv`, `rm`, etc]
  The _source_ e.g. #ls-sources is the start of the pipeline, it exclusively produces
output. The _sink_ is the end of the pipeline, it exclusively consumes
the input. In-between are _filters_ e.g. #ls-filters where data are passed in-and-out
and get transformed in the process #fn[in the context of a pipeline-based
system architecture, these are called _middle-wares_]. So, a simple pipeline
is one with a structure source-filter-sink. A complex pipeline is one that
can "branch" ; the way to branch is to organize each pipeline branch as
each group of commands as in \@fn, then use special filters to branch on
conditions using redirections with named pipes #fn[in practice, this is
rarely done]. The rest are _cantrips_ e.g. #(ls-cantrips)--commands that don't produce output
but instead apply an effect onto the current environment.\
  It's worth noting that, even on the conceptual level, the evaluation
order of the part commands is that all commands start simultaneously when
a pipeline runs. For a pipeline that runs persistently, all pipes must
run concurrently and persistently as well. This is contrary to the semantics
of pipeline seen elsewhere e.g. functional programming.\
  For the #o.bkhack-shell language, pipelining is first-class citizen.
The grammar expects all commands to unequivocally form a pipeline, as
evident by @gr, and multiple groups of commands will connect to form
complex pipelines that branch.
== Composition via function <fn>
A reusable pipeline or grouping of commands would be called a _function_
. In the #o.bkhack-shell language, #lorem(70)\
#lorem(70). Function is a useful abstraction. For example, since feed can be treated as a function simply built-in, it's possible to customize the behavior of ```sh feed``` by overloading it. Indeed, the default ```sh feed``` command in #o.bkhack, which automatically has limiting of 15 items pagination, is simply a function
```sh
feed() { feed | split -c 15 | cut -f1 | sort --hot ;}
```
which the user can customize. The rest of #o.bkhack-shell commands are
exposed like so, thus the settings system.
== Variation via flags
#lorem(30)
== Variation via subcommands
#lorem(30)
== Syntax
Sometimes, it is needed to parse the shell language from a text.
The grammar of the #o.bkhack-shell language, given in EBNF form in @gr, #lorem(30)
Notice how the command rule do not distinguish parts into flags or values
which are expected from most real-world usage. Indeed, the responsibility
of interpreting these parts, a.k.a. _options_, is left to the higher-level
_option parser_, such as POSIX `getopts`.
#place(auto, float: true, scope: "parent")[
  #figure(caption: [Grammar for the #o.bkhack-shell language], shell-parse.langchain) <gr>
]
=== Parsing the shell language
Parsing is implemented based on the grammar at @gr. #lorem(30) For example, one possible parse of the command at the preamble is
#align(center)[
#tdtr.tidy-tree-graph(compact: true)[
  #let sink(n) = tdtr.node-attr(sink: n)
  - $< "program" >$
    - command
      - word
        - ```sh feed```
    - ```sh |``` #sink(2)
    - command
      - word
        - ```sh split```
      - word
        - ```sh -c```
      - word
        - ```sh 10```
]
]
where #lorem(20)
  In the initial design, we have only one phase for our parser. This is an eager, AST-less, final a.k.a. _syntax-directed_ parser--effects are eagerly executed as each term is parsed. Eventually, we did make it so that it outputs an AST, for reusability and convenience.\
  In the next design, we have two phases for our parser. The lexical analysis phase (bộ phân tích từ vựng @giao-trinh-trinh-bien-dich-lexer) #fn[a.k.a. character grouping] and the parsing phase. The lexical analysis phase is to guarantee a minimal schema for the parsers so that they won't diverge from the language spec. This is an implicit structure. In contrast, we could have defined an ADT or GADT to make an explicit structure. However, our parsers won't be final, we would make a compromise on performance. Not only that, an implicit structure allows room for undefined behaviors; each parser can do things in flexible ways that should hopefully achieve desirable results.\
  Indeed, the lexing phase was added when we branched the parser to support _pastelling_; so, two parsers, a parser and a pastel. A shared lexing phase helps communicating that the two parsers share a structure, even if that structure is only infra-, and ter'es no explicit GADT or signature to explicitly enforce it.\
  The usefulness of this starts to show when we added a new feature: support for quoted words. Thanks to the two-phase separation, we managed to implement this feature simply by modifying the lexer. We added new parsing rule, and changed the return type of $<"word">$. This cascades into all descendant parsers, requiring them to handle the new feature. Here, they are being rewritten by adding a new $<"word">$ overloading guard before usage.
== Typing
Sometimes, it is useful to verify the shell language before evalutation.
The typing of the #o.bkhack-shell language, given in @typ, #lorem(30)
This is useful when shell commands have to be embedded in a statically-typed
programming language.
#place(auto, float: true, scope: "parent")[
  #figure(caption: [Typing for the #o.bkhack-shell language], shell-sym.v) <typ>
]
=== Embedding the shell language
The combinators are designed based on the typing rules at @typ. #lorem(30)\
  #lorem(50) An example usage of these combinators would be
#set raw(syntaxes: ("reason.sublime-syntax")/* , theme: "quiet.tmTheme" */)
#[
```reason
module Feed (Syntax : Shell.Sym)
{ open Syntax
  let rec v = () =>
  { feed |@ Split_by.count(10) |@ nil ;}
  and v' = () => observe @@ v() }
```
]
where the ```reason |@``` operator--accompanied by the ```reason nil``` word to mark EOL--is a semantic translation of ```sh |``` as part of an abstract algebra used to construct an embedded #o.bkhack-shell pipeline, and 
#lorem(50)\
  We believe that this type system can be used for composition of commands. Indeed, _type-driven composition_ allows us to implement and explore possibilities purely through types, where the type system serves as a real-time theorem checker that prompts our paths. For example, #lorem(20)
== Completion
When writing a pipeline, it is nice to provide a language service where user can request their partially-written command to be replaced with corrected form.
When press #kbd.keys(kbd.o.tab()) user #lorem(30)
// #kbd.keys(kbd.meta-[x], kbd.cmd("package-refresh-contents"), kbd.enter())
== Convention
why are commands named the way they are? this is the same problem in sh. the truth is that there will never be a scheme that everyone can agree on. most names are historical and highly contextual. unix is loved because people like its architecture and they try to adopt the names, not that the names are actually good. indeed, there's so much you can do to appeal to a demographic of people. communication is two-way between the user and the developer.
== Related works
#lorem(20)\
  Stream programming languages. #lorem(50)\
  Shell languages. #lorem(50)\
== Further exercises
#lorem(20)\
  #lorem(20)
#bibliography(title: none, "./works.bib")
// fr1: the api should be monadic like cetz.canvas and diagram.fletcher
// fr2: the output should look like HTML kbd elements, like https://github.com/elixir-editors/emacs-elixir
// vi: set nowrap:
