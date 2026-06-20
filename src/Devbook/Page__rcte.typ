#import "/article": *
#import "Vocab.typ" as o
#title[= Design of the #o.bkhack comment-tree]
```sh
discuss $id | limit 3
```
// #set raw(theme: "quiet.tmTheme")
```elixir
base_query =
  from(c in Comment)
  |> select([c], c)
  |> then(fn x -> case {parent_id,parent_type} do
    {-1,_}         -> x
    {_,"post"}    -> x |> where([c], c.parent_post_id    == ^parent_id)
    {_,"comment"} -> x |> where([c], c.parent_comment_id == ^parent_id)
    {_,_}          -> x
  end end)

recursive_query =
  from(c in Comment)
  |> join(:inner, [c], ct in "comment_tree", on: ct.comment_id == c.parent_comment_id)
  |> select([c, ct], c)

comment_tree =
  base_query
  |> union(^recursive_query)
```
// vi: set nowrap:
