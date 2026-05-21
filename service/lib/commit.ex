defmodule CommitBE do
  def insertCommit(commit_owner_id,post_title,post_text,commit_message) do
    changeset = Commit.changeset(%Commit{}, %{
      commit_owner_id:  commit_owner_id,
      post_title:       post_title,
      post_text:        post_text,
      commit_message:   commit_message
    })
    Data0.insert(changeset)
  end
  def updateCommitChild do
  end
  def getCommit do
  end
  def getAll do
    import Ecto.Query
    query = from u in Commit, select: u
    xs = Data0.all(query)
    IO.inspect xs
  end
end
