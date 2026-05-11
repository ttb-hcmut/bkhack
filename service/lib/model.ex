defmodule User
  do use Ecto.Schema
  @primary_key {:user_id, :id, autogenerate: true}
  schema "users" do
    field :name, :string
    field :password, :string
    field :email, :string
    field :role, :integer
  end
end
defmodule Post
  do use Ecto.Schema
  @primary_key {:post_id, :id, autogenerate: true}
  schema "posts" do
    field :post_title ,:string
    field :creator_id ,:integer
    field :post_text  ,:string
    belongs_to  :the_creator ,User  ,foreign_key: :creator_id ,references: :user_id ,define_field: false
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
