defmodule App do
  require Logger
  use Plug.Router

  plug :match
  plug :dispatch

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
    {:ok, _} = Plug.Cowboy.http(__MODULE__, [], port: 5000)
    Logger.info "running server!"
  end

  def stop do
    :ok = Plug.Cowboy.shutdown(__MODULE__.HTTP)
    Logger.info "stopped server"
  end
end
