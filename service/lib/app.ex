defmodule Data0 do
  use Ecto.Repo, otp_app: :bkhack, adapter: Ecto.Adapters.SQLite3
end

defmodule Data1 do
  use Ecto.Repo, otp_app: :bkhack, adapter: Mongo.Ecto
end

defmodule User
  do use Ecto.Schema
  @primary_key false

  schema "users" do
    field :user_id, :integer
    field :name
  end

  def changeset(user, params \\ %{}) do
    import Ecto.Changeset
    user
    |> cast(params, [:user_id, :name])
    |> validate_required([:user_id, :name])
  end

end


defmodule App
  do use Plug.Router
  require Logger

  plug :match
  plug :dispatch

  import Ecto.Query

  get "/api/test/users" do
    query = from u in User, select: u
    xs = Data0.all(query)
    lol = xs |> Enum.map(fn it -> [user_id: it.user_id, name: it.name] end)
    {:ok, sh} = JSON.encode(lol)
    conn
    |> put_resp_header("Access-Control-Allow-Origin", "*")
    |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
    |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
    |> put_resp_content_type("application/json")
    |> send_resp(200, sh)
  end

  get "/api/test-item" do
    Logger.info "GET test-item"
    lol = [
      title: "Về IMGUI và những paradigm con",
      author: "lyan3002",
      rank: 12,
      posts: [
        [
          id: "9aw62813",
          author: "dan_o55",
          message: "Tui cũng không biết nữa"
        ],
        [
          author: "sdf",
          message: "sdf"
        ],
        [
          id: "sd324",
          author: "kinten",
          message: "yes",
          reply_to: "9aw62813",
        ],
      ]
    ]
    {:ok, sh} = JSON.encode(lol)
    conn
    # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
    |> put_resp_header("Access-Control-Allow-Origin", "*")
    |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
    |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
    |> put_resp_content_type("application/json")
    |> send_resp(200, sh)
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  def start do
    App.Supervisor.start_link(:ok)
    {:ok, _} = Plug.Cowboy.http(__MODULE__, [], port: 5000)
    Logger.info "running server!"
  end

  def stop do
    :ok = Plug.Cowboy.shutdown(__MODULE__.HTTP)
    Logger.info "stopped server"
  end

end

defmodule App.Supervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      Data0,
      Data1
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
