defmodule PostBE do
  import Ecto.Query
  def createPost(creator_id,post_title,post_text,commit_message,public)do
    query = from u in User, select: u.role, where: u.user_id == ^creator_id
    role = Data0.one(query)
    res = Data0.transact(fn ->
      with {:ok, commit} <- CommitBE.insertCommit(creator_id,post_title,post_text,commit_message)
      do
        changeset = Post.changeset(%Post{}, %{
          post_owner_id:  creator_id,
          commit_head_id: commit.commit_id,
          verified:       (role != 1), # 1 => prof
          public:         public,
        })
        Data0.insert(changeset)
      end
    end)
    case res do
      {:ok,post} -> post.post_id
      {:error,cs} -> IO.inspect(cs); nil
    end
  end
  def updatePost(post_id,creator_id,post_title,post_text,commit_message) do
    res = Data0.transact(fn ->
      with {:ok, newCommit} <- CommitBE.insertCommit(creator_id,post_title,post_text,commit_message),
           post           <- from(u in Post, where: u.post_id == ^post_id) |> Data0.one,
           commit         <- from(u in Commit, where: u.commit_id == ^newCommit.commit_id) |> Data0.one,
           _updatedCommit <- commit |> Commit.changeset(%{commit_child_id: post.commit_head_id}) |> Data0.update,
           _updatedPost   <- post |> Post.changeset(%{commit_head_id: commit.commit_id}) |> Data0.update
      do
        {:ok,:balls}
      else
        nil -> Data0.rollback(:got_nil)
        {:error, reason} -> Data0.rollback(reason)
      end
    end)
    IO.inspect res
  end
  def getPostList(
      user_id\\-1,
      search\\"",
      searchby\\"title",
      sortby\\"age",
      orderby\\"ascending",
      limit\\10,
      offset\\0,
      count\\false
    ) do
    base_query =
      Commit
      |> join(:inner, [c], p in Post, on: c.commit_id == p.commit_head_id)
      |> select([c,p], %{pid: p.post_id,cid: c.commit_id, child_id: c.commit_child_id})

    recursive_query =
      Commit
      |> join(:inner, [c], ct in "descendants", on: c.commit_id == ct.child_id)
      |> select([c, ct], %{pid: ct.pid, cid: c.commit_id, child_id: c.commit_child_id})

    descendants_query =
      base_query
      |> union_all(^recursive_query)

    res =
      Post
      |> recursive_ctes(true)
      |> with_cte("descendants", as: ^descendants_query)
      |> join(:left,[p],d in "descendants", on: p.post_id == d.pid)
      |> join(:left,[p,d], c in Commit, on: p.commit_head_id == c.commit_id)
      |> join(:left,[p,d,c], u in User, on: p.post_owner_id == u.user_id)
      |> group_by([p,d,c,u], p.post_id)
      |> select([p,d,c,u], %{
        post_id:    p.post_id,
        owner_id:   p.post_owner_id,
        owner_name: u.name,
        title:      c.post_title,
        version:    count(p.post_id),
        verified:   p.verified,
        created:    p.date_created_utc,
        updated:    c.date_created_utc,
        })
      |> then(fn x -> (case user_id do
          -1 -> x |> where([p,d,c,u], p.public == true)
          u  -> x |> where([p,d,c,u], p.public == true or p.post_owner_id == ^u)
        end)
      end)
      |> then(fn x -> (case {search,searchby} do
          {"", _ }      -> x
          {s, "title" } -> x |> where([p,d,c,u], like(c.post_title, ^"%#{s}%"))
          {s, "body"  } -> x |> where([p,d,c,u], like(c.post_body , ^"%#{s}%"))
          {s, "author"} -> x |> where([p,d,c,u], like(u.name      , ^"%#{s}%"))
          { _ , _ }     -> x
        end)
      end)
      |> then(fn x -> (case {sortby,orderby} do
          {"age"    ,"ascending"  } -> x |> order_by([p,d,c,u], asc:  p.date_created_utc)
          {"age"    ,"descending" } -> x |> order_by([p,d,c,u], desc: p.date_created_utc)
          {"active" ,"ascending"  } -> x |> order_by([p,d,c,u], asc:  c.date_created_utc)
          {"active" ,"descending" } -> x |> order_by([p,d,c,u], desc: c.date_created_utc)
          { _ , _ }     -> x
        end)
      end)
      |> then(fn x -> (case count do
          true  -> from(n in subquery(x), select: count(n.post_id) ) |> Data0.one
          false -> x |> limit(^limit) |> offset(^offset) |> Data0.all
        end)
      end)

    res
  end
  def getAll do
    query = from u in Post, select: u
    xs = Data0.all(query)
    IO.inspect xs
  end
end
