defmodule PullrequestBE do
  import Ecto.Query
  def createPullrequest(data, creator_id,post_id,post_title,post_text,commit_message,tag)do
    query = from u in Post, select: u.commit_head_id, where: u.post_id == ^post_id
    head_id = data.one(query)
    res = data.transact(fn ->
      with {:ok, commit} <- CommitBE.insertCommit(data, creator_id,post_title,post_text,commit_message),
           {:ok, _}      <- TagBE.addCommitTags(data, commit.commit_id, tag)
      do
        changeset = Pullrequest.changeset(%Pullrequest{}, %{
          user_id:      creator_id,
          post_id:      post_id,
          post_head_id: head_id,
          commit_id:    commit.commit_id,
          title:        commit_message,
          status:       "open"
        })
        data.insert(changeset)
      end
    end)
    case res do
      {:ok,pr} -> pr.pr_id
      {:error,cs} -> IO.inspect(cs); nil
    end
  end
  # def updatePullrequest(data, pr_id,creator_id,status) do
  #   {:ok,res} = data.transact(fn ->
  #     with {:ok, newCommit} <- CommitBE.insertCommit(data, creator_id,post_title,post_text,commit_message),
  #          %Post{} = post     <- from(u in Post, where: u.post_id == ^post_id and u.post_owner_id == ^creator_id)|> select([u],u) |> data.one,
  #          %Commit{} = commit <- from(u in Commit, where: u.commit_id == ^newCommit.commit_id) |> select([u],u) |> data.one,
  #          {:ok, _}       <- TagBE.addCommitTags(data, newCommit.commit_id, tag),
  #          _updatedCommit <- commit |> Commit.changeset(%{commit_child_id: post.commit_head_id}) |> data.update,
  #          _updatedPost   <- post |> Post.changeset(%{commit_head_id: commit.commit_id}) |> data.update
  #     do
  #       {:ok,post.post_id}
  #     else
  #       nil -> data.rollback(:got_nil); {:error,-1}
  #       {:error, reason} -> data.rollback(reason); {:error,-1}
  #     end
  #   end)
  #   res
  # end
  def getPullrequestCount(data, post_id\\nil, opts\\ %{}) do
    query = pullrequestListQuery(post_id)
    |> pullrequestFilter(opts) |> select([c],c)
    from(n in subquery(query), select: count(n.pr_id) ) |> data.one
  end
  def getPullrequestList(data, post_id\\nil, limit\\10, offset\\0, opts\\%{}) do
    pullrequestListQuery(post_id)
    |> pullrequestFilter(opts)
    |> limit(^limit) |> offset(^offset) |> data.all
  end
  # def getPullrequestHead(data, post_id, user_id\\-1)do
  #   with %Post{} = p <- Post |> select([p],p)|> where([p], p.post_id == ^post_id) |> data.one,
  #         true     <- p.public or (p.post_owner_id == user_id and user_id !=-1)
  #   do Post
  #     |> join(:left,[p], c in Commit, on: p.commit_head_id == c.commit_id)
  #     |> join(:left,[p,c], u in User, on: u.user_id == p.post_owner_id)
  #     |> select([p,c,u], %{
  #       post_id:     p.post_id    ,
  #       title:       c.post_title ,
  #       body:        c.post_text  ,
  #       owner_name:  u.name       ,
  #       owner_id:    ^p.post_owner_id ,
  #       })
  #     |> where([p,c,u], p.post_id == ^p.post_id)
  #     |> data.one
  #   else
  #     nil -> nil
  #   end
  # end

  defp pullrequestListQuery(post_id\\nil) do
    Pullrequest
    |> join(:left,[p], c in Commit, on: p.commit_id == c.commit_id)
    |> join(:left,[p,c], u in User, on: p.user_id == u.user_id)
    |> select([p,c,u], %{
      user_id:          p.user_id          ,
      user_name:        u.name             ,
      post_id:          p.post_id          ,
      post_head_id:     p.post_head_id     ,
      commit_id:        c.commit_id        ,
      title:            p.title            ,
      status:           p.status           ,
      date_created_utc: p.date_created_utc
      })
    |> then(fn x -> case post_id do
        nil -> x |> where([p,c,u], p.post_id == -1)
        u   -> x |> where([p,c,u], p.post_id == ^post_id)
    end end)
  end
  defp pullrequestFilter(x, opts\\%{}) do
    from(c in subquery(x))
    |> then(fn xx -> case {opts[:search],opts[:searchby]} do
        {s,o} when is_nil(s) or length(s) == 0 or is_nil(o) -> xx
        {s, "title" } -> xx|> where([p], like(p.title     , ^"%#{s}%"))
        {s, "author"} -> xx|> where([p], like(p.user_name, ^"%#{s}%"))
        { _ , _ }     -> xx
    end end)
    |> then(fn xx -> case {opts[:sortby],opts[:orderby]} do
      {s,o} when is_nil(s) or is_nil(o) -> xx
      {"age","ascending"}     -> xx |> order_by([p], asc:  p.created)
      {"age","descending"}    -> xx |> order_by([p], desc: p.created)
      {_,_}                   -> xx
    end end)
  end

  def getAll(data) do
    query = from u in Pullrequest, select: u
    xs = data.all(query)
    IO.inspect xs
  end
end
