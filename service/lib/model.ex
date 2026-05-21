
import Ecto.Changeset
defmodule User
  do use Ecto.Schema
  @primary_key {:user_id, :id, autogenerate: true}
  schema "users" do
    field :name, :string
    field :password, :string
    field :email, :string
    field :role, :integer # 0 => student; 1 => prof
  end
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :password, :role])
    |> validate_required([:email, :name, :password, :role])
    |> unique_constraint(:name, name: :users_name_index)
    |> validate_email()
    |> validate_username()
    |> validate_password()
  end
  defp validate_email(changeset) do
    changeset
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/,
        message: "invalid email address"
      )
  end
  defp validate_username(changeset) do
    changeset
    |> validate_length(:name,
        min: 1,
        message: "username is empty"
      )
    |> validate_format(:name, ~r/^[a-z0-9]+$/,
        message: "username contains characters not allowed"
      )
  end
  defp validate_password(changeset) do
    changeset
    |> validate_length(:password,
        min: 8,
        message: "password less than 8 characters long"
      )
  end
end
defmodule Post
  do use Ecto.Schema
  @timestamps_opts [type: UTCDateTime]
  @primary_key {:post_id, :id, autogenerate: true}
  schema "posts" do
    field :commit_head_id ,:integer
    field :post_owner_id  ,:integer
    field :verified       ,:boolean ,default: false
    field :public         ,:boolean ,default: false
    timestamps(inserted_at: :date_created_utc, updated_at: false, type: :utc_datetime)
    belongs_to  :the_owner  ,User   ,foreign_key: :post_owner_id  ,references: :user_id   ,define_field: false
    belongs_to  :the_commit ,Commit ,foreign_key: :commit_head    ,references: :commit_id ,define_field: false
  end
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:post_owner_id, :commit_head_id, :verified, :public])
    |> validate_required([:post_owner_id, :commit_head_id])
  end
end
defmodule Commit
  do use Ecto.Schema
  @timestamps_opts [type: UTCDateTime]
  @primary_key {:commit_id, :id, autogenerate: true}
  schema "commits" do
    field :commit_owner_id  ,:integer
    field :commit_child_id  ,:integer ,default: nil
    field :commit_message   ,:string
    field :post_title       ,:string
    field :post_text        ,:string
    timestamps(inserted_at: :date_created_utc, updated_at: false, type: :utc_datetime)
    belongs_to  :the_owner  ,User   ,foreign_key: :commit_owner_id  ,references: :user_id   ,define_field: false
    belongs_to  :the_child  ,Commit ,foreign_key: :child_commit_id  ,references: :commit_id ,define_field: false
  end
  def changeset(commit, attrs) do
    commit
    |> cast(attrs, [:commit_owner_id, :commit_child_id, :commit_message, :post_text, :post_title])
    |> validate_required([:commit_owner_id, :commit_message, :post_title, :post_text])
  end
end
defmodule Comment
  do use Ecto.Schema
  @timestamps_opts [type: UTCDateTime]
  @primary_key {:comment_id,:id,autogenerate: true}
  schema "comments" do
    field :parent_post_id    ,:integer
    field :parent_comment_id ,:integer
    field :content           ,:string
    field :commenter_id      ,:integer
    timestamps(inserted_at: :date_created_utc, updated_at: false, type: :utc_datetime)
    # field :date_created_utc  ,:string
    field :post_version      ,:integer
    belongs_to  :the_parent_post    ,Post     ,foreign_key: :parent_post_id    ,references: :post_id     ,define_field: false
    belongs_to  :the_parent_comment ,Comment  ,foreign_key: :parent_comment_id ,references: :comment_id  ,define_field: false
    belongs_to  :the_commenter      ,User     ,foreign_key: :commenter_id      ,references: :user_id     ,define_field: false
  end
end
defmodule CommentRating
  do use Ecto.Schema
  @primary_key {:comment_rating_id, :id, autogenerate: true}
  schema "commentratings" do
    field :voter_id   ,:integer
    field :comment_id ,:integer
    field :rating     ,:integer
    belongs_to  :the_voter    ,User    ,foreign_key: :voter_id   ,references: :user_id    ,define_field: false
    belongs_to  :the_comment  ,Comment ,foreign_key: :comment_id ,references: :comment_id ,define_field: false
  end
end
