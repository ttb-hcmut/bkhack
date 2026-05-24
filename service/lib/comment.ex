defmodule DiscussionBE do
  import Ecto.Query
  def getCommentCount(parent_id,parent_type\\"post",recursive\\false,opts\\%{}) do
    query = case recursive do
      false -> discussionQuery(parent_id,parent_type,nil)|> discussionFilter(opts) |> select([c],c)
      true  -> fromCommentTree(parent_id,parent_type) |> select([ct],%{id: ct.comment_id})
    end
    from(n in subquery(query), select: count(n.id)) |> Data0.one
  end

  def getComment(parent_id,parent_type\\"post",user_id\\nil,offset\\0,limit\\10,opts\\%{}) do
    discussionQuery(parent_id,parent_type,user_id)
    |> discussionFilter(opts)
    |> limit(^limit) |> offset(^offset) |> Data0.all
  end

  defp fromCommentTree(parent_id\\-1,parent_type\\"post")do
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

    from(ct in "comment_tree") |> recursive_ctes(true) |> with_cte("comment_tree", as: ^comment_tree)
  end
  defp discussionFilter(x, opts\\%{}) do
    from(c in subquery(x))
      |> then(fn xx -> case {opts[:search],opts[:searchby]} do
        {s,o} when is_nil(s) or is_nil(o) -> xx
        {s,"comment"}   -> xx |> where([c], like(c.text, ^"%#{s}%"))
        {s,"username"}  -> xx |> where([c], like(c.author_name, ^"%#{s}%"))
        # {s,"version"} when Integer.parse(s) == {int,""}   -> xx |> where([c], c.post_vers == ^String.to_int(s))
        {_,_}           -> xx
      end end)
      |> then(fn xx -> case opts[:filterby] do
        s when is_nil(s) or s == "none" -> xx
        "prof"         -> xx |> where([c], c.author_role == 1)
        "student"      -> xx |> where([c], c.author_role == 0)
        _ -> xx
      end end)
      |> then(fn xx -> case {opts[:sortby],opts[:orderby]} do
        {s,o} when is_nil(s) or is_nil(o) -> xx
        {"age","ascending"}         -> xx |> order_by([c], asc:  c.timestamp)
        {"age","descending"}        -> xx |> order_by([c], desc: c.timestamp)
        {"popularity","ascending"}  -> xx |> order_by([c], asc:  c.rating)
        {"popularity","descending"} -> xx |> order_by([c], desc: c.rating)
        {_,_}                       -> xx
      end end)
  end
  defp discussionQuery(parent_id,parent_type\\"post",user_id\\nil) do
    query = case parent_type do
      "post"    -> from(c in Comment) |> where([c],c.parent_post_id == ^parent_id)
      "comment" -> from(c in Comment) |> where([c],c.parent_comment_id == ^parent_id)
    end
    comment_sum_ratings =
      from(c in subquery(query|> select([c],%{comment_id: c.comment_id})))
      |> join(:left,[c], r in CommentRating, on: c.comment_id == r.comment_id)
      |> select([c,r], %{
        comment_id: c.comment_id,
        commentsumratings: coalesce(sum(r.rating),0),
        })
      |> group_by([c,r], c.comment_id)

    comment_rating =
      from(c in subquery(query|> select([c],%{comment_id: c.comment_id})))
      |> join(:left,[c], r in CommentRating, on: c.comment_id == r.comment_id)
      |> select([c,r], %{
        comment_id: c.comment_id,
        rating:     r.rating,})
      |> then(fn x -> case is_nil(user_id) do
        true ->  x |> where([c,r], r.voter_id != r.voter_id)
        false -> x |> where([c,r], r.voter_id == ^user_id)
      end end)

    full_query =
      from(c in subquery(query|> select([c],c)))
      |> join(:left,[c], r in subquery(comment_rating), on: c.comment_id == r.comment_id)
      |> join(:left,[c,r], sr in subquery(comment_sum_ratings), on: c.comment_id == sr.comment_id)
      |> join(:left,[c,r,sr], u in User, on: c.commenter_id == u.user_id)
      |> select([c,r,sr,u], %{
        id:           c.comment_id,
        text:         c.content,
        user_rating:  coalesce(r.rating,0),
        rating:       sr.commentsumratings,
        timestamp:    c.date_created_utc,
        post_vers:    c.post_version,
        author_name:  u.name,
        author_id:    u.user_id,
        author_role:  u.role })
    full_query
  end

   # def fromCommentTree(parent_id\\-1,parent_type\\"post",opts\\%{}) do
  #   base_query =
  #     from(c in Comment)
  #     |> select([c], c)
  #     |> then(fn x -> case {parent_id,parent_type} do
  #       {-1,_}        -> x
  #       {_,"post"}    -> x |> where([c], c.parent_post_id    == ^parent_id)
  #       {_,"comment"} -> x |> where([c], c.parent_comment_id == ^parent_id)
  #       {_,_}         -> x
  #     end end)
  #   recursive_query =
  #     from(c in Comment)
  #     |> join(:inner, [c], ct in "comment_tree", on: ct.comment_id == c.parent_comment_id)
  #     |> select([c, ct], c)
  #   comment_tree =
  #     base_query
  #     |> union(^recursive_query)

  #   from(ct in "comment_tree") |> recursive_ctes(true) |> with_cte("comment_tree", as: ^comment_tree)
  # end

  # def getPostComments(user_id\\0,post_id\\0,offset\\0,limit\\10) do
  #   query = """
  #     WITH commentsumratings as (
  #       SELECT comment_id, SUM(CASE WHEN rating = 1 THEN 1 ELSE -1 END) as total
  #       FROM commentratings
  #       GROUP BY comment_id
  #     )
  #     SELECT
  #       c.comment_id as id,
  #       c.content as text,
  #       SUM(CASE WHEN r.voter_id = ? THEN r.rating ELSE 0 END) as user_rating,
  #       CASE WHEN s.total IS NOT NULL then s.total else 0 end as rating,
  #       c.date_created_utc as timestamp,
  #       c.post_version as post_vers,
  #       u.name as author_name,
  #       u.user_id as author_id,
  #       u.role as author_role
  #     FROM comments c
  #     LEFT JOIN commentratings r on c.comment_id = r.comment_id
  #     LEFT JOIN commentsumratings s on c.comment_id = s.comment_id
  #     LEFT JOIN users u on c.commenter_id = u.user_id
  #     where c.parent_post_id = ?
  #     group by id
  #     ORDER BY id
  #     LIMIT ?
  #     OFFSET ?
  #   """
  #   {:ok,result} = Ecto.Adapters.SQL.query(Data0, query,[user_id,post_id,limit,offset])
  #   columns = Enum.map(result.columns, fn c -> String.to_atom(c) end)
  #   result.rows |> Enum.map(fn row -> Enum.zip(columns, row) end)
  # end

  # def getCommentReplies(user_id\\0,comment_id\\0,offset\\0,limit\\10) do
  #   query = """
  #     WITH commentsumratings as (
  #       SELECT comment_id, SUM(CASE WHEN rating = 1 THEN 1 ELSE -1 END) as total
  #       FROM commentratings
  #       GROUP BY comment_id
  #     )
  #     SELECT
  #       c.comment_id as id,
  #       c.content as text,
  #       SUM(CASE WHEN r.voter_id = ? THEN r.rating ELSE 0 END) as user_rating,
  #       CASE WHEN s.total IS NOT NULL then s.total else 0 end as rating,
  #       c.date_created_utc as timestamp,
  #       c.post_version as post_vers,
  #       u.name as author_name,
  #       u.user_id as author_id,
  #       u.role as author_role
  #     FROM comments c
  #     LEFT JOIN commentratings r on c.comment_id = r.comment_id
  #     LEFT JOIN commentsumratings s on c.comment_id = s.comment_id
  #     LEFT JOIN users u on c.commenter_id = u.user_id
  #     where c.parent_comment_id = ?
  #     group by id
  #     ORDER BY id
  #     LIMIT ?
  #     OFFSET ?
  #   """
  #   {:ok,result} = Ecto.Adapters.SQL.query(Data0, query,[user_id,comment_id,limit,offset])
  #   columns = Enum.map(result.columns, fn c -> String.to_atom(c) end)
  #   result.rows |> Enum.map(fn row -> Enum.zip(columns, row) end)
  # end

  def setVote(voter_id,comment_id,action) do
    from(r in CommentRating, where: r.comment_id == ^comment_id and r.voter_id == ^voter_id )
    |> Data0.delete_all()

    if action == -1 || action == 1 do
      Data0.insert!(%CommentRating{voter_id: voter_id, comment_id: comment_id, rating: action})
    end

  end

  def postComment(parent_id,parent_type,content,commenter_id,post_version) do
    case parent_type do
      0 -> Data0.insert!(%Comment{
        parent_post_id:     parent_id, parent_comment_id:  nil, content:            content, commenter_id:       commenter_id, post_version:       post_version
      })
      1 -> Data0.insert!(%Comment{
        parent_post_id:     nil, parent_comment_id:  parent_id, content:            content, commenter_id:       commenter_id, post_version:       post_version
      })
      _ -> nil
    end
  end

  def getCommentAll do
    query = from u in Comment, select: u
    xs = Data0.all(query)
    IO.inspect xs
  end

end
