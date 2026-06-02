module AuthContext = {
  type t = {
    getUserId   : unit => option(int)
  , getUserName : unit => option(string)
  , forceAuth   : unit => unit
  , checkAuth   : unit => bool
  , setAuthFromToken : (Js.Json.t) => unit
  , unsetAuth   : unit => unit
  , withAuth    : (bool) => Js.Json.t
  };

  let defaultValue: t = {
    getUserId   : () => None
  , getUserName : () => None
  , forceAuth   : (_) => ()
  , checkAuth   : () => false
  , setAuthFromToken : (_) => ()
  , unsetAuth   : () => ()
  , withAuth    : (_) => Js.Json.null
  };

  let ctx = React.createContext(defaultValue);

  module Provider (C : Decorator.Component) = {
    [@react.component]
    let make = () => {
      let url = ReasonReactRouter.useUrl();
      let setAuth = (userId:int,userName:string,timeout:int, token:Js.Json.t) => {
        Dom.Storage.localStorage |> Dom.Storage.setItem("bkhack.auth.id", string_of_int(userId));
        Dom.Storage.localStorage |> Dom.Storage.setItem("bkhack.auth.name", userName);
        Dom.Storage.localStorage |> Dom.Storage.setItem("bkhack.auth.timeout", string_of_int(timeout));
        Dom.Storage.localStorage |> Dom.Storage.setItem("bkhack.auth.jwttoken", Js.Json.stringify(token))
      }
      let unsetAuth = () => {
        Dom.Storage.localStorage |> Dom.Storage.removeItem("bkhack.auth.id");
        Dom.Storage.localStorage |> Dom.Storage.removeItem("bkhack.auth.name");
        Dom.Storage.localStorage |> Dom.Storage.removeItem("bkhack.auth.timeout");
        Dom.Storage.localStorage |> Dom.Storage.removeItem("bkhack.auth.jwttoken")
      }
      let checkAuth = () => {
        let id          = Dom.Storage.localStorage |> Dom.Storage.getItem("bkhack.auth.id")
        let name        = Dom.Storage.localStorage |> Dom.Storage.getItem("bkhack.auth.name")
        let timeout     = Dom.Storage.localStorage |> Dom.Storage.getItem("bkhack.auth.timeout")
        let jsonToken   = Dom.Storage.localStorage |> Dom.Storage.getItem("bkhack.auth.jwttoken")
        switch (id,name,timeout,jsonToken) {
          | (None,_,_,_) | (_,None,_,_) | (_,_,None,_) | (_,_,_,None) => false
          | (_,_,Some(t),_) => int_of_string(t) > int_of_float(Js.Date.now())/1000
        }
      }
      let forceAuth : unit => 'a = () => {
        unsetAuth()
        let redirect = "/" ++ (url.path |> List.map(x =>x ++ "/") |> String.concat @@ "") ++ (if(String.length(url.search)>0){"?" ++ url.search}else{""})
        Js__dom.Window.Location.href_set(
          "/auth/?redirect=" ++ (
            redirect
            |> Js.Global.encodeURIComponent
          )
        );  
      } 
      let setAuthFromToken = (json) => {
        open Model.JWTToken;
        json
        |> Model.Decode.jwtToken
        |> (aod) => {
          setAuth(aod.user_id,aod.user_name,aod.timeout,json)
        }
      };
      let withAuth = (forced:bool) => {
        let token = Dom.Storage.localStorage |> Dom.Storage.getItem("bkhack.auth.jwttoken") 
        switch(forced, token){ 
        | (true, None) => {forceAuth(); Js.Json.null}
        | (false, None) => Js.Json.null
        | (_, Some(t)) => t|> Js.Json.parseExn
      }
      };
      // let refreshJWT = () => {
      //   open Fetch__syntax;
      //   open Js.Json;
      //   open Json__syntax;
      //   checkAuth()
      //   |> fun
      //   | false => forceAuth()
      //   | true =>
      //     Fetch.fetchWithInit(
      //       Env.backend ++"/api/auth/refreshjwt",
      //       Fetch.RequestInit.make(
      //         ~method_=Post,
      //         ~body=Fetch.BodyInit.make(Js.Json.stringify(
      //           empty() |> withAuth |> finish
      //         )),
      //         ~headers=Fetch.HeadersInit.make({
      //           "Content-Type": "application/json"
      //         }),
      //         ()
      //       )
      //     )
      //     >>= Fetch.Response.json
      //     >>= (json => {
      //       json
      //       |> fun
      //       | j when j == Js.Json.null => {Js.log("refreshing JWT failed"); forceAuth()}
      //       | j => setAuthFromToken(j);
      //       return(j)
      //     })
      //     >!= (err => {
      //         Js.log(err);
      //         Js.Promise.resolve(Js.Json.null)
      //       })
      //     |> ignore;
      // }
      let ctxValue: t = {
        getUserId   : () => Dom.Storage.localStorage |> Dom.Storage.getItem("bkhack.auth.id") |> a => switch(a){ | Some(v) => Some(int_of_string(v)) | _ => None }
      , getUserName : () => Dom.Storage.localStorage |> Dom.Storage.getItem("bkhack.auth.name")
      , forceAuth   : forceAuth
      , checkAuth   : checkAuth
      , setAuthFromToken : setAuthFromToken
      , unsetAuth   : unsetAuth
      , withAuth    : withAuth
      };

      let provider = React.Context.provider(ctx);
      React.createElement(provider, {"value": ctxValue, "children": <C />})
    };
  };

  let use = () => React.useContext(ctx);
};