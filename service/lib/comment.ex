defmodule DiscussionBE do
  import Ecto.Query
  def getCommentsCount(post_id\\0) do
    query = """
      WITH RECURSIVE all_comments AS (
        SELECT comment_id, parent_post_id AS post_id
        FROM comments
        WHERE parent_post_id IS NOT NULL

        UNION ALL

        SELECT n.comment_id, an.post_id
        FROM comments n
        INNER JOIN all_comments an ON n.parent_comment_id = an.comment_id
      )
      SELECT
        COUNT(comment_id) as total_comment_count
      FROM all_comments
      where post_id = ?
    """
    {:ok,result} = Ecto.Adapters.SQL.query(Data0, query,[post_id])
    result.rows |> List.first() |> List.first()
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
