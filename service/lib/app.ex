defmodule Data0 do
  use Ecto.Repo, otp_app: :bkhack, adapter: Ecto.Adapters.SQLite3
end
# defmodule Data1 do
#   use Ecto.Repo, otp_app: :bkhack, adapter: Mongo.Ecto
# end
# defmodule Data2 do
#   use Ecto.Repo, otp_app: :bkhack, adapter: Ecto.Adapters.Postgres
# end

alias Data0, as: Data

defmodule App
  do
  use Plug.Router
  use Application
  require Logger
  require Db
  require ReturnChildID
  require DiscussionBE
  require AuthBE

  plug :match
  plug Plug.Parsers, parsers: [:json], json_decoder: JSON
  plug :fetch_query_params
  plug :dispatch

  def put_resp_free(conn) do
    conn
    # reference: https://elixirforum.com/t/how-to-properly-implement-cors-in-plug-cowboy-served-rest-api/36186
    |> put_resp_header("Access-Control-Allow-Origin", "*")
    |> put_resp_header("Access-Control-Allow-Method", "POST, GET, PATCH, OPTIONS")
    |> put_resp_header("Access-Control-Allow-Headers", "Origin, X-Requested-With, jwterrible, Content-Type, Accept")
    |> put_resp_content_type("application/json")
  end
  def getJWTToken(conn) do
    IO.puts("getting jwterrible")
    case Plug.Conn.get_req_header(conn, "jwterrible")|>JSON.decode do
    {:ok, %{
      "user_id"   => user_id  ,
      "user_name" => user_name,
      "sign_at"   => sign_at  ,
      "timeout"   => timeout  ,
      "hash"      => hash
    }} -> %{
      user_id:    user_id  ,
      user_name:  user_name,
      sign_at:    sign_at  ,
      timeout:    timeout  ,
      hash:       hash
    }
    _ -> nil
    end
  end
  def jwtReader(conn,field,default) do
    token     = getJWTToken(conn)
    case token do
      nil -> default
      _ ->   if(AuthBE.testJWT(token)) do Map.get(token,field) else default end
    end
  end
  get "/api/tag/commit" do
    Logger.info "GET committag"
    commitid = Map.get(conn.params,"commitid", nil) |> then(fn x -> if is_nil(x) do nil else x |> String.to_integer end end)
    data = TagBE.getCommitTag(Data,commitid)
    case data do
      nil ->
        {:ok, sh} = JSON.encode([])
        conn
        |> put_resp_free
        |> send_resp(501 , sh)
      x ->
        {:ok, sh} = Jason.encode(x)
        conn
        |> put_resp_free
        |> send_resp(200 , sh)
    end
  end
  get "/api/tag/post" do
    Logger.info "GET posttag"
    postid = Map.get(conn.params,"postid", nil) |> then(fn x -> if is_nil(x) do nil else x |> String.to_integer end end)
    data = TagBE.getPostTag(Data,postid)
    case data do
      nil ->
        {:ok, sh} = JSON.encode([])
        conn
        |> put_resp_free
        |> send_resp(501 , sh)
      x ->
        {:ok, sh} = Jason.encode(x)
        conn
        |> put_resp_free
        |> send_resp(200 , sh)
    end
  end
  get "/api/tag/list" do
    Logger.info "GET taglist"
    data = TagBE.getTagAll(Data)
    case data do
      nil ->
        {:ok, sh} = JSON.encode([])
        conn
        |> put_resp_free
        |> send_resp(501 , sh)
      x ->
        {:ok, sh} = Jason.encode(x)
        conn
        |> put_resp_free
        |> send_resp(200 , sh)
    end
  end
  get "/api/history/count" do
    Logger.info "GET historycount"
    postid = Map.get(conn.params,"postid", nil) |> then(fn x -> if is_nil(x) do nil else x |> String.to_integer end end)
    opts = %{
      search:   Map.get(conn.params,"search", "") |> URI.decode,
      searchby: Map.get(conn.params,"searchby", nil),
      sortby:   Map.get(conn.params,"sortby", nil),
      orderby:  Map.get(conn.params,"orderby", nil)
    }

    data = CommitBE.getPostHistoryCount(Data, postid, opts)
    case data do
      nil ->
        {:ok, sh} = JSON.encode([])
        conn
        |> put_resp_free
        |> send_resp(501 , sh)
      x ->
        {:ok, sh} = Jason.encode(x)
        conn
        |> put_resp_free
        |> send_resp(200 , sh)
    end
  end
  get "/api/history/list" do
    Logger.info "GET historylist"
    postid = Map.get(conn.params,"postid", nil) |> then(fn x -> if is_nil(x) do nil else x |> String.to_integer end end)
    offset = Map.get(conn.params,"offset","0") |> String.to_integer
    limit  = Map.get(conn.params,"limit","10") |> String.to_integer

    opts = %{
      search:   Map.get(conn.params,"search", "") |> URI.decode,
      searchby: Map.get(conn.params,"searchby", nil),
      sortby:   Map.get(conn.params,"sortby", nil),
      orderby:  Map.get(conn.params,"orderby", nil)
    }

    data = CommitBE.getPostHistoryList(Data, postid, limit, offset, opts)
    # data = ReturnChildID.getChildComments(parent, offset, limit)
    case data do
      nil ->
        {:ok, sh} = JSON.encode([])
        conn
        |> put_resp_free
        |> send_resp(501 , sh)
      x ->
        {:ok, sh} = Jason.encode(x)
        conn
        |> put_resp_free
        |> send_resp(200 , sh)
    end
  end

  get "/api/post/get" do
    Logger.info "GET post"
    post_id   = Map.get(conn.params,"post_id" ,"-1" ) |> String.to_integer
    version   = Map.get(conn.params,"v"       ,"latest"  )
    user_id = jwtReader(conn,:user_id,-1)
    data = case version do
      "latest" -> PostBE.getPostHead(Data, post_id, user_id)
      _ -> nil
    end
    # data = ReturnChildID.getChildComments(parent, offset, limit)
    case data do
      nil ->
        {:ok, sh} = JSON.encode([])
        conn
        |> put_resp_free
        |> send_resp(501 , sh)
      x ->
        {:ok, sh} = Jason.encode(x)
        conn
        |> put_resp_free
        |> send_resp(200 , sh)
    end
  end

  get "/api/post/count" do
    Logger.info "GET postcount"
    user_id = jwtReader(conn,:user_id,-1)

    opts = %{
      search:   Map.get(conn.params,"search", "") |> URI.decode,
      searchby: Map.get(conn.params,"searchby", nil),
      sortby:   Map.get(conn.params,"sortby", nil),
      orderby:  Map.get(conn.params,"orderby", nil)
    }

    data = PostBE.getPostCount(Data, user_id, opts)
    # data = ReturnChildID.getChildComments(parent, offset, limit)
    case data do
      nil ->
        {:ok, sh} = JSON.encode([])
        conn
        |> put_resp_free
        |> send_resp(501 , sh)
      x ->
        {:ok, sh} = Jason.encode(x)
        conn
        |> put_resp_free
        |> send_resp(200 , sh)
    end
  end
  get "/api/post/list" do
    Logger.info "GET postlist"
    offset    = Map.get(conn.params,"offset","0") |> String.to_integer
    limit     = Map.get(conn.params,"limit","10") |> String.to_integer
    user_id = jwtReader(conn,:user_id,-1)


    opts = %{
      search:   Map.get(conn.params,"search", "") |> URI.decode,
      searchby: Map.get(conn.params,"searchby", nil),
      sortby:   Map.get(conn.params,"sortby", nil),
      orderby:  Map.get(conn.params,"orderby", nil)
    }

    data = PostBE.getPostList(Data, user_id, limit, offset, opts)
    # data = ReturnChildID.getChildComments(parent, offset, limit)
    case data do
      nil ->
        {:ok, sh} = JSON.encode([])
        conn
        |> put_resp_free
        |> send_resp(501 , sh)
      x ->
        {:ok, sh} = Jason.encode(x)
        conn
        |> put_resp_free
        |> send_resp(200 , sh)
    end
  end

  options "/*_" do
    conn
    |> put_resp_free
    |> send_resp(200, "")
  end

  post "/api/post/create" do
    Logger.info "POST create post"
    body = conn.body_params
    IO.inspect conn.body_params
    title       = body["title"]
    post_body   = body["body"]
    commit_message = body["commit_message"]
    public      = body["public"]
    post_id     = body["post-id"]
    tag         = body["tag"]
    user_id = jwtReader(conn,:user_id,-1)


    data = "User "<>Integer.to_string(user_id)<>" with title: "<>title<>" and body: "<>post_body
    IO.puts(data);
    case user_id do
      -1 ->
        {:ok, sh} = JSON.encode([])
        conn
        |> put_resp_free
        |> send_resp(403 , sh)
      _ ->
        postId = case post_id do
          -1 ->  PostBE.createPost(Data, user_id, title, post_body, commit_message, public, tag)
          pid -> PostBE.updatePost(Data, pid, user_id, title, post_body, commit_message, tag)
        end
        case postId do
          nil ->
            {:ok, sh} = JSON.encode(-1)
            conn
            |> put_resp_free
            |> send_resp(500, sh)
          p ->
            {:ok, sh} = JSON.encode(p)
            conn
            |> put_resp_free
            |> send_resp(201, sh)
        end
    end
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
    isAnythingWrongOfficer = AuthBE.register(Data, username,password,email)
    IO.puts("--");IO.puts(isAnythingWrongOfficer);
    case String.length(isAnythingWrongOfficer) do
      0 ->
        {:ok, sh} = JSON.encode("")
        conn
        |> put_resp_free
        |> send_resp(201, sh)
      _ ->
        {:ok, sh} = JSON.encode(isAnythingWrongOfficer)
        conn
        |> put_resp_free
        |> send_resp(500, sh)
    end
  end
  post "/api/auth/login" do
    Logger.info "POST login"
    body = conn.body_params
    IO.inspect conn.body_params
    username  = body["username"]
    password  = body["password"]

    data = "User "<>username<>" trying to login with password \""<>password
    IO.puts(data);
    acc = AuthBE.login(Data, username,password)
    case acc do
      nil ->
        {:ok, sh} = JSON.encode("Wrong login dumb fuck")
        conn
        |> put_resp_free
        |> send_resp(500, sh)
      info ->
        {:ok, sh} = JSON.encode(info)
        conn
        |> put_resp_free
        |> send_resp(201, sh)
    end
  end


  get "/api/comment/count" do
    Logger.info "GET commentcount"
    type      = Map.get(conn.params,"type"     ,nil)
    parent    = Map.get(conn.params,"parent"   ,nil)
    recursive = Map.get(conn.params,"recursive","false")
    opts = %{
      search:   Map.get(conn.params,"search", "") |> URI.decode,
      searchby: Map.get(conn.params,"searchby", nil),
      sortby:   Map.get(conn.params,"sortby", nil),
      orderby:  Map.get(conn.params,"orderby", nil),
      filterby: Map.get(conn.params,"filterby", nil)
    }
    IO.inspect conn.params
    IO.inspect {type,parent,recursive}
    data = case {type,parent} do
      {_, nil} -> nil
      {"post",p}    -> DiscussionBE.getCommentCount(Data, p |> String.to_integer, "post", recursive=="true" , opts)
      {"comment",p} -> DiscussionBE.getCommentCount(Data, p |> String.to_integer, "comment", recursive=="true", opts)
      {_,_}-> nil
    end

    # data = ReturnChildID.getChildComments(parent, offset, limit)
    case data do
      nil ->
        {:ok, sh} = JSON.encode(nil)
        conn
        |> put_resp_free
        |> send_resp(501 , sh)
      x ->
        {:ok, sh} = Jason.encode(x)
        conn
        |> put_resp_free
        |> send_resp(200 , sh)
    end
  end
  get "/api/comment/get" do
    Logger.info "GET comment"
    type   = Map.get(conn.params,"type"  ,"post")
    parent = Map.get(conn.params,"parent",nil)
    offset = Map.get(conn.params,"offset","0")
    limit  = Map.get(conn.params,"limit","10")
    user_id = jwtReader(conn,:user_id,nil)


    opts = %{
      search:   Map.get(conn.params,"search", "") |> URI.decode,
      searchby: Map.get(conn.params,"searchby", nil),
      sortby:   Map.get(conn.params,"sortby", nil),
      orderby:  Map.get(conn.params,"orderby", nil),
      filterby: Map.get(conn.params,"filterby", nil)
    }

    data = case {parent,type} do
      {p,t} when not is_nil(p) and t in ["post","comment"]-> DiscussionBE.getComment(Data, parent,type,user_id,offset,limit,opts)
      _ -> nil
    end

    # data = ReturnChildID.getChildComments(parent, offset, limit)
    case data do
      nil ->
        {:ok, sh} = JSON.encode([])
        conn
        |> put_resp_free
        |> send_resp(501 , sh)
      x ->
        {:ok, sh} = Jason.encode(x)
        conn
        |> put_resp_free
        |> send_resp(200 , sh)
    end
  end
  post "/api/postcomment" do
    Logger.info "POST comment"
    body = conn.body_params
    IO.inspect conn.body_params
    id      = body["id"]
    type    = body["type"]
    content = body["content"]
    version = body["post_version"]
    user_id = jwtReader(conn,:user_id,-1)


    data = "User "<>Integer.to_string(user_id)<>" commented \""<>content<>"\" on "<>Integer.to_string(type)<>" "<>Integer.to_string(id)
    IO.puts(data);
    data = DiscussionBE.postComment(Data, id, type, content, user_id, version)

    case {data,user_id} do
      {_,-1} ->
        {:ok, sh} = JSON.encode([])
        conn
        |> put_resp_free
        |> send_resp(403 , sh)
      {nil,_} ->
        {:ok, sh} = JSON.encode([])
        conn
        |> put_resp_free
        |> send_resp(501 , sh)
      {x,_} ->
        {:ok, sh} = Jason.encode(data.comment_id)
        conn
        |> put_resp_free
        |> send_resp(200 , sh)
    end
  end
  post "/api/setvote" do
    Logger.info "POST vote"
    body = conn.body_params
    id      = body["id"]
    type    = body["type"]
    action  = body["action"]
    user_id = jwtReader(conn,:user_id,-1)


    data = "User "<>Integer.to_string(user_id)<>" voted "<>Integer.to_string(action)<>" on "<>type<>" "<>Integer.to_string(id)
    IO.puts(data);
    data = DiscussionBE.setVote(Data, user_id,id,action)
    case {data,user_id} do
      {_,-1} ->
        {:ok, sh} = JSON.encode([])
        conn
        |> put_resp_free
        |> send_resp(403 , sh)
      {nil,_} ->
        {:ok, sh} = JSON.encode([])
        conn
        |> put_resp_free
        |> send_resp(501 , sh)
      {x,_} ->
        {:ok, sh} = Jason.encode(data)
        conn
        |> put_resp_free
        |> send_resp(201, sh)
    end
  end

  post "/api/test/free" do
    r = Ecto.Adapters.SQL.query!(Data, conn.query_params["query"], [])
    xs = r.rows
    lol = xs
    {:ok, sh} = JSON.encode(lol)
    conn
    |> put_resp_free
    |> send_resp(200, sh)
  end

  get "/api/test" do
    Logger.info "GET test"
    data = [
      message: "icle",
    ]
    {:ok, sh} = JSON.encode(data)
    conn
    |> put_resp_free
    |> send_resp(200, sh)
  end

  get "/api/test/users" do
    import Ecto.Query
    query = from u in User, select: u
    xs = Data.all(query)
    lol = xs |> Enum.map(fn it -> [user_id: it.user_id, name: it.name] end)
    {:ok, sh} = JSON.encode(lol)
    conn
    |> put_resp_free
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
    |> put_resp_free
    |> send_resp(200, sh)
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  @impl true
  def start(_type, _args) do
    {:ok, pid} = App.Supervisor.start_link(:ok)
    {:ok, _} = Plug.Cowboy.http(__MODULE__, [ip: {0, 0, 0, 0}], port: 5000)
    {:ok, pid}
  end

  def start do
    if File.exists? "lock" do
      {:error, :already_running, msg: "server is already running"}
    else
      {:ok, pid} = App.Supervisor.start_link(:ok)
      {:ok, lock} = File.open("lock", [:write])
      :ok = IO.write(lock, :erlang.pid_to_list(pid))
      :ok = File.close(lock)
      {:ok, _} = Plug.Cowboy.http(__MODULE__, [ip: {0, 0, 0, 0}], port: 5000)
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

  def start_link(args), do: Supervisor.start_link(__MODULE__, args, name: __MODULE__)

  @impl true
  def init(_init_arg) do
    children = [
      # Data,
      # Data1
      Data,
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

  def start_link(args), do: GenServer.start_link(__MODULE__, args)

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
