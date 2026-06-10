defmodule PostBE do
  import Ecto.Query
  def createPost(data, creator_id,post_title,post_text,commit_message,public,tag)do
    query = from u in User, select: u.role, where: u.user_id == ^creator_id
    role = data.one(query)
    res = data.transact(fn ->
      with {:ok, commit} <- CommitBE.insertCommit(data, creator_id,post_title,post_text,commit_message),
           {:ok, _}      <- TagBE.addCommitTags(data, commit.commit_id, tag)
      do
        changeset = Post.changeset(%Post{}, %{
          post_owner_id:  creator_id,
          commit_head_id: commit.commit_id,
          verified:       (role != 1), # 1 => prof
          public:         public,
        })
        data.insert(changeset)
      end
    end)
    case res do
      {:ok,post} -> post.post_id
      {:error,cs} -> IO.inspect(cs); nil
    end
  end
  def updatePost(data, post_id,creator_id,post_title,post_text,commit_message, tag) do
    {:ok,res} = data.transact(fn ->
      with {:ok, newCommit} <- CommitBE.insertCommit(data, creator_id,post_title,post_text,commit_message),
           %Post{} = post     <- from(u in Post, where: u.post_id == ^post_id and u.post_owner_id == ^creator_id)|> select([u],u) |> data.one,
           %Commit{} = commit <- from(u in Commit, where: u.commit_id == ^newCommit.commit_id) |> select([u],u) |> data.one,
           {:ok, _}       <- TagBE.addCommitTags(data, newCommit.commit_id, tag),
           _updatedCommit <- commit |> Commit.changeset(%{commit_child_id: post.commit_head_id}) |> data.update,
           _updatedPost   <- post |> Post.changeset(%{commit_head_id: commit.commit_id}) |> data.update
      do
        {:ok,post.post_id}
      else
        nil -> data.rollback(:got_nil); {:error,-1}
        {:error, reason} -> data.rollback(reason); {:error,-1}
      end
    end)
    res
  end
  def getPostCount(data, user_id\\-1, opts\\ %{}) do
    query = postListQuery(user_id)
    |> postFilter(opts) |> select([c],c)
    from(n in subquery(query), select: count(n.post_id) ) |> data.one
  end
  def getPostList(data, user_id\\-1, limit\\10, offset\\0, opts\\%{}) do
    postListQuery(user_id)
    |> postFilter(opts)
    |> limit(^limit) |> offset(^offset) |> data.all
  end
  def getPostHead(data, post_id, user_id\\-1)do
    with %Post{} = p <- Post |> select([p],p)|> where([p], p.post_id == ^post_id) |> data.one,
          true     <- p.public or (p.post_owner_id == user_id and user_id !=-1)
    do Post
      |> join(:left,[p], c in Commit, on: p.commit_head_id == c.commit_id)
      |> join(:left,[p,c], u in User, on: u.user_id == p.post_owner_id)
      |> select([p,c,u], %{
        post_id:     p.post_id    ,
        title:       c.post_title ,
        body:        c.post_text  ,
        owner_name:  u.name       ,
        owner_id:    ^p.post_owner_id ,
        })
      |> where([p,c,u], p.post_id == ^p.post_id)
      |> data.one
    else
      nil -> nil
    end
  end

  defp postListQuery(user_id\\-1) do
    Post
    |> recursive_ctes(true)
    |> with_cte("descendants", as: ^CommitBE.commitDescendantsQuery())
    |> join(:left,[p],d in "descendants", on: p.post_id == d.post_id)
    |> join(:left,[p,d], c in Commit, on: p.commit_head_id == c.commit_id)
    |> join(:left,[p,d,c], u in User, on: p.post_owner_id == u.user_id)
    |> group_by([p,d,c,u], [u.name, p.post_id, c.post_title, c.date_created_utc])
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
    |> then(fn x -> case user_id do
        -1 -> x |> where([p,d,c,u], p.public == true)
        u  -> x |> where([p,d,c,u], p.public == true or p.post_owner_id == ^u)
    end end)
  end
  defp postFilter(x, opts\\%{}) do
    from(c in subquery(x))
    |> then(fn xx -> case {opts[:search],opts[:searchby]} do
        {s,o} when is_nil(s) or length(s) == 0 or is_nil(o) -> xx
        {s, "title" } -> xx|> where([p], like(p.title     , ^"%#{s}%"))
        {s, "author"} -> xx|> where([p], like(p.owner_name, ^"%#{s}%"))
        { _ , _ }     -> xx
    end end)
    |> then(fn xx -> case {opts[:sortby],opts[:orderby]} do
      {s,o} when is_nil(s) or is_nil(o) -> xx
      {"age","ascending"}     -> xx |> order_by([p], asc:  p.created)
      {"age","descending"}    -> xx |> order_by([p], desc: p.created)
      {"active","ascending"}  -> xx |> order_by([p], asc:  p.updated)
      {"active","descending"} -> xx |> order_by([p], desc: p.updated)
      {_,_}                   -> xx
    end end)
  end

  def getAll(data) do
    query = from u in Post, select: u
    xs = data.all(query)
    IO.inspect xs
  end
end
