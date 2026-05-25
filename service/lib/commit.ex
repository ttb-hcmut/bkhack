defmodule CommitBE do
  def insertCommit(data, commit_owner_id,post_title,post_text,commit_message) do
    changeset = Commit.changeset(%Commit{}, %{
      commit_owner_id:  commit_owner_id,
      post_title:       post_title,
      post_text:        post_text,
      commit_message:   commit_message
    })
    data.insert(changeset)
  end
  def updateCommitChild do
  end
  def getCommit do
  end
  def getAll(data) do
    import Ecto.Query
    query = from u in Commit, select: u
    xs = data.all(query)
    IO.inspect xs
  end
end
