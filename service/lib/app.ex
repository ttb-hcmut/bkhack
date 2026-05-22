defmodule Data0 do
  use Ecto.Repo, otp_app: :bkhack, adapter: Ecto.Adapters.SQLite3
end
defmodule Data1 do
  use Ecto.Repo, otp_app: :bkhack, adapter: Mongo.Ecto
end

defmodule App
  do use Plug.Router
  require Logger
  require Db
  require ReturnChildID
  require DiscussionBE
  require AuthBE

  plug :match
  plug Plug.Parsers,
    parsers: [:json],
    json_decoder: JSON
  plug :fetch_query_params
  plug :dispatch

  get "/api/post/get" do
    Logger.info "GET post"
    post_id   = Map.get(conn.params,"post_id" ,"-1" ) |> String.to_integer
    user_id   = Map.get(conn.params,"user_id" ,"-1" ) |> String.to_integer
    version   = Map.get(conn.params,"v"       ,"latest"  )


    data = case version do
      "latest" -> PostBE.getPostHead(post_id, user_id)
      _ -> nil
    end
    # data = ReturnChildID.getChildComments(parent, offset, limit)
    case data do
      nil ->
        {:ok, sh} = JSON.encode([])
        conn
        # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
        |> put_resp_header("Access-Control-Allow-Origin", "*")
        |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
        |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
        |> put_resp_content_type("application/json")
        |> send_resp(501 , sh)
      x ->
        {:ok, sh} = Jason.encode(x)
        conn
        # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
        |> put_resp_header("Access-Control-Allow-Origin", "*")
        |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
        |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
        |> put_resp_content_type("application/json")
        |> send_resp(200 , sh)
    end
  end

  get "/api/post/list" do
    Logger.info "GET postlist"
    user      = Map.get(conn.params,"user"     ,"-1"        ) |> String.to_integer
    search    = Map.get(conn.params,"search"   ,""          )
    searchby  = Map.get(conn.params,"searchby" ,"title"     )
    sortby    = Map.get(conn.params,"sortby"   ,"age"       )
    orderby   = Map.get(conn.params,"orderby"  ,"ascending" )
    offset    = Map.get(conn.params,"offset","0") |> String.to_integer
    limit     = Map.get(conn.params,"limit","10") |> String.to_integer
    count     = if(Map.get(conn.params,"count" ,"false") == "true", do: true , else: false)

    data = PostBE.getPostList(
      user,
      search,
      searchby,
      sortby,
      orderby,
      limit,
      offset,
      count
    )
    # data = ReturnChildID.getChildComments(parent, offset, limit)
    case data do
      nil ->
        {:ok, sh} = JSON.encode([])
        conn
        # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
        |> put_resp_header("Access-Control-Allow-Origin", "*")
        |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
        |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
        |> put_resp_content_type("application/json")
        |> send_resp(501 , sh)
      x ->
        {:ok, sh} = Jason.encode(x)
        conn
        # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
        |> put_resp_header("Access-Control-Allow-Origin", "*")
        |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
        |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
        |> put_resp_content_type("application/json")
        |> send_resp(200 , sh)
    end
  end
  options "/api/post/create" do
    conn
    # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
    |> put_resp_header("Access-Control-Allow-Origin", "*")
    |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
    |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
    |> send_resp(200, "")
  end
  post "/api/post/create" do
    Logger.info "POST create post"
    body = conn.body_params
    IO.inspect conn.body_params
    creator_id  = body["id"]
    title       = body["title"]
    post_body   = body["body"]
    commit_message = body["commit_message"]
    public      = body["public"]
    post_id     = body["post-id"]

    data = "User "<>Integer.to_string(creator_id)<>" with title: "<>title<>" and body: "<>post_body
    IO.puts(data);
    postId = case post_id do
      -1 ->  PostBE.createPost(creator_id, title, post_body, commit_message, public)
      pid -> PostBE.updatePost(pid, creator_id, title, post_body, commit_message)
    end
    case postId do
      nil ->
        {:ok, sh} = JSON.encode(-1)
        conn
        # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
        |> put_resp_header("Access-Control-Allow-Origin", "*")
        |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
        |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
        |> put_resp_content_type("application/json")
        |> send_resp(500, sh)
      p ->
        {:ok, sh} = JSON.encode(p)
        conn
        # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
        |> put_resp_header("Access-Control-Allow-Origin", "*")
        |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
        |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
        |> put_resp_content_type("application/json")
        |> send_resp(201, sh)
    end
  end
  options "/api/auth/register" do
    conn
    # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
    |> put_resp_header("Access-Control-Allow-Origin", "*")
    |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
    |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
    |> send_resp(200, "")
  end
  post "/api/auth/register" do
    Logger.info "POST register"
    body = conn.body_params
    IO.inspect conn.body_params
    username  = body["username"]
    password  = body["password"]
    email     = body["email"]

    data = "Registering "<>username<>" with password "<>password<>" and email "<>email
    IO.puts(data);
    isAnythingWrongOfficer = AuthBE.register(username,password,email)
    IO.puts("--");IO.puts(isAnythingWrongOfficer);
    case String.length(isAnythingWrongOfficer) do
      0 ->
        {:ok, sh} = JSON.encode("")
        conn
        # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
        |> put_resp_header("Access-Control-Allow-Origin", "*")
        |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
        |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
        |> put_resp_content_type("application/json")
        |> send_resp(201, sh)
      _ ->
        {:ok, sh} = JSON.encode(isAnythingWrongOfficer)
        conn
        # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
        |> put_resp_header("Access-Control-Allow-Origin", "*")
        |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
        |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
        |> put_resp_content_type("application/json")
        |> send_resp(500, sh)
    end
  end

  options "/api/auth/login" do
    conn
    # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
    |> put_resp_header("Access-Control-Allow-Origin", "*")
    |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
    |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
    |> send_resp(200, "")
  end
  post "/api/auth/login" do
    Logger.info "POST login"
    body = conn.body_params
    IO.inspect conn.body_params
    username  = body["username"]
    password  = body["password"]

    data = "User "<>username<>" trying to login with password \""<>password
    IO.puts(data);
    acc = AuthBE.login(username,password)
    case acc do
      nil ->
        {:ok, sh} = JSON.encode("Wrong login dumb fuck")
        conn
        # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
        |> put_resp_header("Access-Control-Allow-Origin", "*")
        |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
        |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
        |> put_resp_content_type("application/json")
        |> send_resp(500, sh)
      info ->
        {:ok, sh} = JSON.encode(info)
        conn
        # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
        |> put_resp_header("Access-Control-Allow-Origin", "*")
        |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
        |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
        |> put_resp_content_type("application/json")
        |> send_resp(201, sh)
    end
  end


  get "/api/comment" do
    Logger.info "GET comment"
    type   = Map.get(conn.params,"type"  ,"0") |> String.to_integer
    parent = Map.get(conn.params,"parent","0") |> String.to_integer
    user   = Map.get(conn.params,"user"  ,"-1")|> String.to_integer
    offset = Map.get(conn.params,"offset","0") |> String.to_integer
    limit  = Map.get(conn.params,"limit","10") |> String.to_integer

    data = case type do
      0 -> DiscussionBE.getCommentsCount(parent)
      1 -> DiscussionBE.getPostComments(user,parent,offset,limit)
      2 -> DiscussionBE.getCommentReplies(user,parent,offset,limit)
      _ -> nil
    end

    # data = ReturnChildID.getChildComments(parent, offset, limit)
    case data do
      nil ->
        {:ok, sh} = JSON.encode([])
        conn
        # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
        |> put_resp_header("Access-Control-Allow-Origin", "*")
        |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
        |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
        |> put_resp_content_type("application/json")
        |> send_resp(501 , sh)
      x ->
        {:ok, sh} = JSON.encode(x)
        conn
        # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
        |> put_resp_header("Access-Control-Allow-Origin", "*")
        |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
        |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
        |> put_resp_content_type("application/json")
        |> send_resp(200 , sh)
    end
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
    IO.inspect conn.body_params
    id      = body["id"]
    type    = body["type"]
    content = body["content"]
    user_id = body["user_id"]
    version = body["post_version"]

    data = "User "<>Integer.to_string(user_id)<>" commented \""<>content<>"\" on "<>Integer.to_string(type)<>" "<>Integer.to_string(id)
    IO.puts(data);
    comment = DiscussionBE.postComment(id, type, content, user_id, version)
    case comment do
      nil ->
        {:ok, sh} = JSON.encode([])
        conn
        # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
        |> put_resp_header("Access-Control-Allow-Origin", "*")
        |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
        |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
        |> put_resp_content_type("application/json")
        |> send_resp(500, sh)
      _ ->
        {:ok, sh} = JSON.encode(comment.comment_id)
        conn
        # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
        |> put_resp_header("Access-Control-Allow-Origin", "*")
        |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
        |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
        |> put_resp_content_type("application/json")
        |> send_resp(201, sh)
    end
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

    data = "User "<>Integer.to_string(user_id)<>" voted "<>Integer.to_string(action)<>" on "<>type<>" "<>Integer.to_string(id)
    IO.puts(data);
    DiscussionBE.setVote(user_id,id,action)
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
    {:ok, _pid} = File.read("lock")
    # NOTE(kinten): reference https://stackoverflow.com/questions/70102293/transform-process-id-pid-in-elixir-to-tuple-or-string-parse-pid-to-other#70105854
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
