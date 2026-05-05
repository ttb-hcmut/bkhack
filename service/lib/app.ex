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
  require Db
  require ReturnChildID

  plug :match
  plug Plug.Parsers,
    parsers: [:json],
    json_decoder: JSON
  plug :fetch_query_params
  plug :dispatch

  get "/api/comment" do
    Logger.info "GET comment"
    parent = Map.get(conn.params,"parent","0")
    offset = String.to_integer(Map.get(conn.params,"offset","0"))
    limit = String.to_integer(Map.get(conn.params,"limit","10"))
    data = ReturnChildID.getChildComments(parent, offset, limit)
    {:ok, sh} = JSON.encode(data)
    conn
    # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
    |> put_resp_header("Access-Control-Allow-Origin", "*")
    |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
    |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
    |> put_resp_content_type("application/json")
    |> send_resp(200, sh)
  end

  options "/api/postcomment" do
    conn
    # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
    |> put_resp_header("Access-Control-Allow-Origin", "*")
    |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
    |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
    |> send_resp(200, "")
  end
  post "/api/postcomment" do
    Logger.info "POST comment"
    body = conn.body_params
    id      = body["id"]
    user_id = body["user_id"]
    type    = body["type"]
    content  = body["content"]

    data = "User "<>user_id<>" commented \""<>content<>"\" on "<>type<>" "<>id
    IO.puts(data);
    {:ok, sh} = JSON.encode(data)
    conn
    # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
    |> put_resp_header("Access-Control-Allow-Origin", "*")
    |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
    |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
    |> put_resp_content_type("application/json")
    |> send_resp(201, sh)
  end

  options "/api/setvote" do
    conn
    # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
    |> put_resp_header("Access-Control-Allow-Origin", "*")
    |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
    |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
    |> send_resp(200, "")
  end
  post "/api/setvote" do
    Logger.info "POST vote"
    body = conn.body_params
    id      = body["id"]
    user_id = body["user_id"]
    type    = body["type"]
    action  = body["action"]

    data = "User "<>user_id<>" voted "<>action<>" on "<>type<>" "<>id
    IO.puts(data);
    {:ok, sh} = JSON.encode(data)
    conn
    # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
    |> put_resp_header("Access-Control-Allow-Origin", "*")
    |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
    |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
    |> put_resp_content_type("application/json")
    |> send_resp(201, sh)
  end

  post "/api/test/free" do
    Logger.info conn
    r = Ecto.Adapters.SQL.query!(Data0, conn.query_params["query"], [])
    xs = r.rows
    lol = xs
    {:ok, sh} = JSON.encode(lol)
    conn
    # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
    |> put_resp_header("Access-Control-Allow-Origin", "*")
    |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
    |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
    |> put_resp_content_type("application/json")
    |> send_resp(200, sh)
  end

  get "/api/test" do
    Logger.info "GET test"
    data = [
      message: "icle",
    ]
    {:ok, sh} = JSON.encode(data)
    conn
    # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
    |> put_resp_header("Access-Control-Allow-Origin", "*")
    |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
    |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
    |> put_resp_content_type("application/json")
    |> send_resp(200, sh)
  end

  get "/api/test/users" do
    import Ecto.Query
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
    if File.exists? "lock" do
      {:error, :already_running, msg: "server is already running"}
    else
      {:ok, pid} = App.Supervisor.start_link(:ok)
      {:ok, lock} = File.open("lock", [:write])
      :ok = IO.write(lock, :erlang.pid_to_list(pid))
      :ok = File.close(lock)
      {:ok, _} = Plug.Cowboy.http(__MODULE__, [], port: 5000)
      {:ok, msg: "running server"}
    end
  end

  def stop() do
    {:ok, pid} = File.read("lock")
    # NOTE(kinten): reference https://stackoverflow.com/questions/70102293/transform-process-id-pid-in-elixir-to-tuple-or-string-parse-pid-to-other#70105854
    pid = pid |> String.to_charlist |> :erlang.list_to_pid
    :ok = Plug.Cowboy.shutdown(__MODULE__.HTTP)
    :ok = File.rm "lock"
    {:ok, msg: "stopped server"}
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
      # Data1
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule App.Book do
  use GenServer

  def start do
    if File.exists? "lock-book" do
      {:error, :already_running, msg: "server book is already running"}
    else
      {:ok, pid} = __MODULE__.start_link []
      {:ok, lock} = File.open "lock-book", [:write]
      :ok = IO.write(lock, :erlang.pid_to_list(pid))
      :ok = File.close(lock)
      {:ok, msg: "running server book"}
    end
  end

  def stop do
    {:ok, pid} = File.read "lock-book"
    # NOTE(kinten): reference https://stackoverflow.com/questions/70102293/transform-process-id-pid-in-elixir-to-tuple-or-string-parse-pid-to-other#70105854
    pid = pid |> String.to_charlist |> :erlang.list_to_pid
    true = Process.exit pid, :normal
    :ok = File.rm "lock-book"
    {:ok, msg: "stopped server book"}
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @impl true
  def init(_state) do
    Process.flag(:trap_exit, true)
    x = Task.async(fn ->
      System.shell "LIVEBOOK_PORT=32123 LIVEBOOK_PASSWORD=ballsballsballs livebook start"
    end)
    {:ok, x}
  end

  @impl true
  def terminate(:normal, x) do
    _ = Task.shutdown(x)
    _ = System.shell "fuser -k 32123/tcp 2>/dev/null"
    :normal
  end

end
