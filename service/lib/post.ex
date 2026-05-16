defmodule PostBE do
  import Ecto.Query
  def createPost(creator_id,post_title,post_text,public)do
    query = from u in User, select: u.role, where: u.user_id == ^creator_id
    xs = Data0.one(query)
    changeset = Post.insert(%Post{}, %{
      post_title: post_title,
      creator_id: creator_id,
      post_text:  post_text,
      public:     public,
      verified:   (xs != 1), # 1 => prof
    })
    case Data0.insert(changeset) do
      {:ok, post} -> post.post_id
      {:error, _} -> nil
    end
  end
  # def updatePost(post_id,content,action)do
  # end
  # def deletePost(post_id)do
  # end
  # def getPost()
end
