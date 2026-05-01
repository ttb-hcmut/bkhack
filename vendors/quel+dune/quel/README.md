# QueL
QueL is a library of language-integrated query based on the tagless-final approach.

Available from http://logic.cs.tsukuba.ac.jp/~ken/quel

Disclaimer: This software is a work-in-progress research prototype,
with some rough edges and features which may not work as expected.
Use of this software is at your sole risk. 

## Build

### Prerequisites
OCaml, version at least 4.0

### Build instructions

Run `make`. 

```
make
```

If all goes well, you should have following libraries.

- quel.cma ... Main library 
- schema1.cma ... The schema definition as an example 
- schema_tlinq.cma ... The schema definition as the example of Cheney et al.'s paper

## Running instructions in the OCaml REPL

To get started, open a terminal window from the directory there are libraries and type `ocaml`.
You'll then be in the OCaml REPL(Real Event Print Loop).

```
OCaml version 4.01.0
#
```

To then include libraries simply load it.

```
#load "quel.cma";;
#load "schema1.cma";;
```


If you want to be able to refer to the contents of the module without this explicit qualification, open `Schema1` module.

```
open Schema1;;
```

QueL term is expressed by combinators based on the tagless final approach. The syntax of QueL and its typing rules are defined as `Symantics` interface in `quel_sym.mli`.

Now, we can write sample terms, such as:

```
module Ex1(S:SYM_SCHEMA) = struct
    open S
    let t1 = observe @@ fun () ->
        (int 1) +% (int 2)
  end;;
(*
   module Ex1 : functor (S : Schema1.SYM_SCHEMA) -> sig val t1 : int S.obs end
*)
```

(The output of the interpreter is shown in comments.)
The name `S` will be used for an instance of `SYM_SCHEMA`.
`SYM_SCHEMA` is a sigunature of combining `Symantics` and the schema.
`Schema1` module defines the schema as an example. The term `(int 1) +% (int 2)` is a sample term in the final form. The type of the term is `int repr`. The type `'a repr` represent the QueL's type. The function `observe` is observe the `'a repr` as a value of some observation type `'a obs`, which is also kept abstract. OCaml's `@@`, like Haskel's `$`, is the low-precedence infix operator for applications.


We stand for _interpreter_, an instance of `SYM_SCHEMA` or `Symantics`.
We can evaluate the example using the R interpreter.

```
let module M = Ex1(R) in M.t1;;
(*  - : int Schema1.R.obs = 3 *)
```

We can also evaluate the example by the P interpreter which interprets every term to a string. Note, the type `'a P.obs` is `string`.

```
let module M = Ex1(P) in M.t1;;
(*  - : int Schema1.P.obs = "1 + 2" *)
```


The following is a simple query.

```
module Ex2(S:SYM_SCHEMA) = struct
  open S
  let products = table ("products", products ())
  let q1 = observe @@ fun () ->
    foreach (fun () -> products) (fun o ->
    yield o)
end;;
(*
  module Ex2 :
  functor (S : Schema1.SYM_SCHEMA) ->
    sig
      val products :
        < category : string; name : string; pid : int; price : int > list
        S.repr
      val q1 :
        < category : string; name : string; pid : int; price : int > list
        S.obs
    end
*)
```

We can evaluate the above to translate an SQL string by the `GenSQL` interpreter.

```
let module M = Ex2(GenSQL) in
  print_endline @@ M.q1;;
;;
(*
  SELECT x.* FROM products AS x WHERE true
 - : unit = () *)
```

## Examples
There are an example of query normalization in `example1.ml`.

## Files
Here is an inventory of the source code in the QueL directory.

- quel_sym.mli: Define Symantics interface as the syntax and its type
- quel_r.ml: The R interpreter
- quel_p.ml: The pretty-printer
- quel_sql.ml: The SQL translator
- quel_o.ml: The optimization framework including the Trans(bwd/fwd) signature
- quel_norm.ml: Normalization rules based on the framework
- test_norm.ml: Test cases for the normalization
- quel_fix.ml: The recursive module to iterate normalizations
- schema1.ml: Define the schema as an example
- schema1.sql: Define SQL queries to setup example schema and data
- example1.ml: Examples
- example2.ml: Small examples
- schema_tlinq.ml:  The schema definition of `compose` example
- schema_tlinq.sql: Setup data for `schema_tlinq.ml`
- example_tlinq.ml: Performance results, the example `compose` in Cheney et al.'s paper
- group.ml: The extension of grouping and its examples
- set.ml: An example of extension that support one of set operations
- lnil.ml: Nil-surpression rule

## Caveats
For brevity, current version of QueL does not access a database server.
GenSQL module generate a real SQL string.
You can use this string to access a database.
If you need database access, you can use the PostgreSQL-OCaml library
that take a SQL string to acccess databases.

   Postgresql-ocaml: http://mmottl.github.io/postgresql-ocaml/
