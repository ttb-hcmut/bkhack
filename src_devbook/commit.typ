#import "/article": *
== Fetching
When fetching commits, it is useful to encode some implicit metadata as concrete fields in the response record. Consider
```elixir
[
  %{
    commit_id: "a799by",
    from_head: 0,
    ...
  },
  %{
    commit_id: "6ccz04",
    from_head: 1,
    ...
  },
]
```
where ```elixir from_head: 1 ``` is the position of the commit in a linked list of commits--post history. Usually, in most SQL applications, sorting and coordination is done by specifying which column to sort. However, in our commits table, there's no stored explicit metadata about the order of items in a linked list. Indeed, index in a linked list is usually implicit. 

In theory, the index position of a list item in a list can be computed through various means. #lorem(30) However, in practice, there are contexts in our system.\
  - The fetching is organized by a pagination of various offsets and limits.\
  - It's possible for the response to be reversed or sorted in varous ways.\
  In other words, list index is not trivial to be inferred.
// vi: set nowrap:
