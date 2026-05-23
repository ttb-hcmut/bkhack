defmodule DiscussionBE do
  import Ecto.Query
  def fromCommentTree(parent_id\\-1,parent_type\\"post",opts\\%{})do
    # filter = fn x ->
    #   x
    #   |> then(fn xx -> case {opts[:search],opts[:search_by]} do
    #     {s,"comment"} -> xx |> where([c], like(c.content, ^"%#{s}%"))
    #     {s,"username"} -> xx |> where([c], like(c.content, ^"%#{s}%"))
    #   end end)
    # end
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
  def getCommentCount(parent_id,parent_type\\"post",recursive\\false) do
    query = case {parent_type,recursive} do
      {"post", false} -> from(c in Comment) |> select([c],%{comment_id: c.comment_id}) |> where([c],c.parent_post_id == ^parent_id)
      {"comment", false} -> from(c in Comment) |> select([c],%{comment_id: c.comment_id}) |> where([c],c.parent_comment_id == ^parent_id)
      {_, true} -> fromCommentTree(parent_id,parent_type) |> select([ct],%{comment_id: ct.comment_id})
    end
    from(n in subquery(query), select: count(n.comment_id)) |> Data0.one |> IO.inspect
  end

  def getPostComments(user_id\\0,post_id\\0,offset\\0,limit\\10) do
    query = """
      WITH commentsumratings as (
        SELECT comment_id, SUM(CASE WHEN rating = 1 THEN 1 ELSE -1 END) as total
        FROM commentratings
        GROUP BY comment_id
      )
      SELECT
        c.comment_id as id,
        c.content as text,
        SUM(CASE WHEN r.voter_id = ? THEN r.rating ELSE 0 END) as user_rating,
        CASE WHEN s.total IS NOT NULL then s.total else 0 end as rating,
        c.date_created_utc as timestamp,
        c.post_version as post_vers,
        u.name as author_name,
        u.user_id as author_id,
        u.role as author_role
      FROM comments c
      LEFT JOIN commentratings r on c.comment_id = r.comment_id
      LEFT JOIN commentsumratings s on c.comment_id = s.comment_id
      LEFT JOIN users u on c.commenter_id = u.user_id
      where c.parent_post_id = ?
      group by id
      ORDER BY id
      LIMIT ?
      OFFSET ?
    """
    {:ok,result} = Ecto.Adapters.SQL.query(Data0, query,[user_id,post_id,limit,offset])
    columns = Enum.map(result.columns, fn c -> String.to_atom(c) end)
    result.rows |> Enum.map(fn row -> Enum.zip(columns, row) end)
  end

  def getCommentReplies(user_id\\0,comment_id\\0,offset\\0,limit\\10) do
    query = """
      WITH commentsumratings as (
        SELECT comment_id, SUM(CASE WHEN rating = 1 THEN 1 ELSE -1 END) as total
        FROM commentratings
        GROUP BY comment_id
      )
      SELECT
        c.comment_id as id,
        c.content as text,
        SUM(CASE WHEN r.voter_id = ? THEN r.rating ELSE 0 END) as user_rating,
        CASE WHEN s.total IS NOT NULL then s.total else 0 end as rating,
        c.date_created_utc as timestamp,
        c.post_version as post_vers,
        u.name as author_name,
        u.user_id as author_id,
        u.role as author_role
      FROM comments c
      LEFT JOIN commentratings r on c.comment_id = r.comment_id
      LEFT JOIN commentsumratings s on c.comment_id = s.comment_id
      LEFT JOIN users u on c.commenter_id = u.user_id
      where c.parent_comment_id = ?
      group by id
      ORDER BY id
      LIMIT ?
      OFFSET ?
    """
    {:ok,result} = Ecto.Adapters.SQL.query(Data0, query,[user_id,comment_id,limit,offset])
    columns = Enum.map(result.columns, fn c -> String.to_atom(c) end)
    result.rows |> Enum.map(fn row -> Enum.zip(columns, row) end)
  end

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
