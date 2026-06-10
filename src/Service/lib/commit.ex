defmodule CommitBE do
  import Ecto.Query
  def insertCommit(data, commit_owner_id,post_title,post_text,commit_message) do
    changeset = Commit.changeset(%Commit{}, %{
      commit_owner_id:  commit_owner_id,
      post_title:       post_title,
      post_text:        post_text,
      commit_message:   commit_message
    })
    data.insert(changeset)
  end
def commitDescendantsQuery(post_id\\nil) do
    base_query =
      Commit
      |> join(:inner, [c], p in Post, on: c.commit_id == p.commit_head_id)
      |> select([c,p], %{
        from_head:        0                  ,
        post_id:          p.post_id          ,
        commit_id:        c.commit_id        ,
        commit_child_id:  c.commit_child_id  ,
        commit_owner_id:  c.commit_owner_id  ,
        commit_message:   c.commit_message   ,
        post_title:       c.post_title       ,
        post_text:        c.post_text        ,
        date_created_utc: c.date_created_utc
        })
      |> then(fn x -> case(post_id) do
        nil -> x
        pid -> x |> where([c,p], p.post_id == ^pid)
      end end)
    recursive_query =
      Commit
      |> join(:inner, [c], ct in "descendants", on: c.commit_id == ct.commit_child_id)
      |> select([c, ct], %{
        from_head:        ct.from_head + 1   ,
        post_id:          ct.post_id         ,
        commit_id:        c.commit_id        ,
        commit_child_id:  c.commit_child_id  ,
        commit_owner_id:  c.commit_owner_id  ,
        commit_message:   c.commit_message   ,
        post_title:       c.post_title       ,
        post_text:        c.post_text        ,
        date_created_utc: c.date_created_utc
        })
    descendants_query =
      base_query
      |> union(^recursive_query)
    descendants_query
  end
  defp postHistoryQuery(post_id\\nil) do
    from(ct in "descendants")
    |> recursive_ctes(true)
    |> with_cte("descendants", as: ^commitDescendantsQuery(post_id))
    |> join(:left,[ct],u in User, on: u.user_id == ct.commit_owner_id)
    |> select([ct,u], %{
      from_head:      ct.from_head      ,
      commit_id:      ct.commit_id      ,
      owner_name:     u.name            ,
      owner_id:       ct.commit_owner_id,
      commit_message: ct.commit_message ,
      post_title:     ct.post_title     ,
      post_text:      ct.post_text      ,
      timestamp:      ct.date_created_utc
      })
  end
  defp postHistoryFilter(x, opts\\%{})do
    from(c in subquery(x))
    |> then(fn xx -> case {opts[:search],opts[:searchby]} do
        {s,o} when is_nil(s) or length(s) == 0 or is_nil(o) -> xx
        {s, "message" } -> xx|> where([p], like(p.commit_message, ^"%#{s}%"))
        {s, "username"} -> xx|> where([p], like(p.owner_name, ^"%#{s}%"))
        {s, "title"}    -> xx|> where([p], like(p.post_title, ^"%#{s}%"))
        {s, "body"}     -> xx|> where([p], like(p.post_text, ^"%#{s}%"))
        { _ , _ }       -> xx
    end end)
    |> then(fn xx -> case {opts[:sortby],opts[:orderby]} do
      {s,o} when is_nil(s) or is_nil(o) -> xx
      {"age","ascending"}     -> xx |> order_by([p], asc:  p.timestamp)
      {"age","descending"}    -> xx |> order_by([p], desc: p.timestamp)
      {"merge","ascending"}   -> xx |> order_by([p], asc:  p.from_head)
      {"merge","descending"}  -> xx |> order_by([p], desc: p.from_head)
      {_,_}                   -> xx
    end end)
  end
  def getPostHistoryCount(data, post_id, opts\\ %{}) do
    query = from(c in subquery(postHistoryQuery(post_id)))
    |> postHistoryFilter(opts) |> select([c],c)
    from(n in subquery(query), select: count(n.commit_id) ) |> data.one
  end
  def getPostHistoryList(data, post_id, limit\\10, offset\\0, opts\\%{})do
    from(c in subquery(postHistoryQuery(post_id)))
    |> postHistoryFilter(opts) |> select([c],c)
    |> limit(^limit) |> offset(^offset) |> data.all
  end
  def getAll(data) do
    query = from u in Commit, select: u
    xs = data.all(query)
    IO.inspect xs
  end
end
