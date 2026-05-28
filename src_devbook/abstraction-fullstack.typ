#import "/article": *
#title[= Abstraction full-stack]
A conventional view of application development would be that the client
and the server form an architecture where the server is the orchestrator
and the client merely fetches and presents. A full-stack developer,
however, would say that this view of the application is not necessary:
the programming of the application is much more abstract and high-level
and is often quite syntactically different from the implementation code
, and that this difference should be reduced. You may perform a fetch
to tier 2--which fetches tier 3--to get some data then deserializes it
; as visualized by a sequence diagram. But your brain may see it as a
single orchestration where data flows from tier 3 to a state variable
in tier 1. At the core of this system is the concept of _flow_--not
the sort of instructions that one might build into a machine or write
a computer program, but the grammar to describe and declare between humans.
// vi: set nowrap:
