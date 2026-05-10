
module AuthContext = {
  type t = {
    getUserId   : unit => option(int)
  , getUserName : unit => option(string)
  , forceAuth   : unit => unit
  , checkAuth   : unit => bool
  , setAuth     : (int,string) => unit
  , unsetAuth   : unit => unit
  };

  let defaultValue: t = {
    getUserId   : () => None
  , getUserName : () => None
  , forceAuth   : (_) => ()
  , checkAuth   : () => false
  , setAuth     : (_,_) => ()
  , unsetAuth   : () => ()
  };

  let ctx = React.createContext(defaultValue);

  module Provider = {
    [@react.component]
    let make = (~children: React.element) => {
      let url = ReasonReactRouter.useUrl();
      let setAuth = (userId:int,userName:string) => {
        // in miliseconds
        let duration = 24 * 60 * 60 * 1000
        Dom.Storage.localStorage |> Dom.Storage.setItem("bkhack.auth.id", string_of_int(userId));
        Dom.Storage.localStorage |> Dom.Storage.setItem("bkhack.auth.name", userName);
        Dom.Storage.localStorage |> Dom.Storage.setItem("bkhack.auth.timeout", string_of_int(int_of_float(Js.Date.now()) + duration));
      }
      let unsetAuth = () => {
        Dom.Storage.localStorage |> Dom.Storage.removeItem("bkhack.auth.id");
        Dom.Storage.localStorage |> Dom.Storage.removeItem("bkhack.auth.name");
        Dom.Storage.localStorage |> Dom.Storage.removeItem("bkhack.auth.timeout");
      }
      let checkAuth = () => {
        let id      = Dom.Storage.localStorage |> Dom.Storage.getItem("bkhack.auth.id")
        let name    = Dom.Storage.localStorage |> Dom.Storage.getItem("bkhack.auth.name")
        let timeout = Dom.Storage.localStorage |> Dom.Storage.getItem("bkhack.auth.timeout")
        switch (id,name,timeout) {
          | (None,_,_) | (_,None,_) | (_,_,None) => false
          | (_,_,Some(t)) => int_of_string(t) > int_of_float(Js.Date.now())
        }
      }
      let forceAuth : unit => 'a = () => {
        Js__dom.Window.Location.href_set(
          "/auth/?redirect=" ++ {
            (String.concat("/",url.path) ++ "/?" ++ url.search)
            |> Js.Global.encodeURI
          }
        );
        
      }
      // let getFromStorage = (~key:string)=>{
      //   switch(key){
      //     | "id" => 0
      //     | "name" => "username"
      //   }
      // }
      // let withAuth = (fn: unit=>'a) =>{
      //   checkAuth()
      //   |> fun
      //     | false => forceAuth()
      //     | true => fn()
      // }
      let ctxValue: t = {
        getUserId   : () => Dom.Storage.localStorage |> Dom.Storage.getItem("bkhack.auth.id") |> a => switch(a){ | Some(v) => Some(int_of_string(v)) | _ => None }
      , getUserName : () => Dom.Storage.localStorage |> Dom.Storage.getItem("bkhack.auth.name")
      , forceAuth   : forceAuth
      , checkAuth   : checkAuth
      , setAuth     : setAuth
      , unsetAuth   : unsetAuth
      };

      let provider = React.Context.provider(ctx);
      React.createElement(provider, {"value": ctxValue, "children": children})
    };
  };

  let use = () => React.useContext(ctx);
};