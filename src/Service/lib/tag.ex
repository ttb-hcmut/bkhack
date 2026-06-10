defmodule TagBE do
  import Ecto.Query
  def attatchTag(data,commit_id,tag_id) do
    data.transact( fn ->
      with %Commit{} <- Commit |> select([u],u) |> where([u],u.commit_id == ^commit_id) |> data.one,
           %Tag{}    <- Tag    |> select([u],u) |> where([u],u.tag_id    == ^tag_id)    |> data.one
      do
        data.insert(%CommitTag{ tag_id: tag_id, commit_id:  commit_id})
      end
    end
    )
  end
  def addCommitTags(data,commit_id,tags)do
    data.transact(fn ->
      {:ok,Enum.map(tags, fn tag ->
        attatchTag(data,commit_id,tag)
      end)}
    end
    )
  end
  defp getCommitTagQuery(commit_id) do
    from(cts in CommitTag)
    |> join(:left,[cts], t in Tag, on: cts.tag_id == t.tag_id)
    |> select([ct,t],%{
      tag_id:    t.tag_id,
      tag_name:  t.tag_name,
      tag_nick:  t.tag_nick,
      tag_color: t.tag_color
    })
    |> where([ct,t],ct.commit_id == ^commit_id)
  end
  def getCommitTag(data,commit_id) do
    getCommitTagQuery(commit_id)
    |> data.all
  end
  def getPostTag(data,post_id) do
    with %Post{} = p <- Post|>select([p],p)|>where([p],p.post_id==^post_id)|>data.one
    do
      getCommitTagQuery(p.commit_head_id)
      |> data.all
    end
  end
  def getTagAll(data,name\\nil) do
    from(t in Tag)
    |> select([t],%{
      tag_id: t.tag_id,
      tag_name: t.tag_name,
      tag_nick:  t.tag_nick,
      tag_color: t.tag_color
      })
    |> then(fn x -> case name do
      nil -> x
      val -> x |> where([t], like(t.tag_name, ^"%#{val}%"))
    end end)
    |> data.all
  end
  def createTag(data,name,nick,color\\0xffffffff) do
    row = data.insert!(%Tag{
        tag_name:     name,
        tag_nick:     nick,
        tag_color:    color
      })
    IO.inspect row
  end
end
