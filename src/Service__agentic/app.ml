let () =
  Dream.run ~port:8067
  @@ Dream.logger
  @@ Dream.router [
    Dream.get "/" (fun _ ->
      Dream.html {|<html><body><script defer src="/static/page__app.bc.js"></script><div id="app"></div></body></html>|});
    Dream.get "/static/**" @@ Dream.static "_build/default/src/Service__agentic"
  ]
