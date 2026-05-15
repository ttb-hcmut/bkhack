#import "/article": *
#let (bkhack, Bkhack) = ([bkhack], [bkhack])
#title[= Stream-based programming, as compared to sh]
For #bkhack, the user gets to familiarize with the concept of _stream-based
programming_. Indeed, visitors of the site will often catch glance of
command hints and tips as they are littered about the user interface.
#lorem(20)\
  Stream programming in #bkhack is sh pipelining, with certain flavorful
differences. The most important difference is that, instead of dealing
with textual data and lines and files, here we deal with abstract post
data and post counts. Consider\
#align(center)[```sh feed | split -c 10 ```]
where ```sh split``` has the option ```sh -c NUM``` where `NUM` is the
count size of each chunk. Conventionally, the POSIX ```sh split``` command
accepts the option ```sh -l NUM``` where `NUM` is line number size of chunk
.\
  Another difference is that there is no filesystem, no concept of space
. There is a command for every page, but there's no way to navigate
"relatively" such as going "back" or "forth"; in other words, there's
no ```sh cd``` command.
== Pipeline
Introduced by Doughlas, pipelining enables commands to compose with each
other parsibly simply via textual data. In this composition, there are
relationships between commands to form the pipeline by parts.\
  The _source_ is the start of the pipeline. #lorem(40) The rest are
_cantraps_--commands that.\
  It's worth noting that, even on the conceptual level, the evaluation
order of the part commands is that all commands start simultaneously when
a pipeline runs.
== Function
A reusable pipeline or grouping of commands would be called a _function_
. In the #bkhack shell language, 
