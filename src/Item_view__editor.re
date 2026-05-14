module PostContext = {
  type t = {
    postBody    : string
  , setPostBody : string => unit
  };

  let defaultValue: t = {
    postBody    : ""
  , setPostBody : (_) => ()
  };

  let ctx = React.createContext(defaultValue);

  module Provider = {
    [@react.component]
    let make = (~children: React.element) => {
      let (postBody,setPostBody) = React.useState( () => "");

      let ctxValue: t = {
        postBody    : postBody
      , setPostBody : (a) => setPostBody(_ => a)
      };

      let provider = React.Context.provider(ctx);
      React.createElement(provider, {"value": ctxValue, "children": children})
    };
  };

  let use = () => React.useContext(ctx);
};


module App = {
  module Header = {
    module Settings = {
      module Tags = {
        [@react.component]
        let make = () => {
          <div className="tags">
            {React.string("Tags")}
          </div>
        }
      };
      module CommitMessage = {
        [@react.component]
        let make = () => {
          <div className="commit-message">
            {React.string("Commit Message")}
          </div>
        }
      };
      module CommitOptions = {
        [@react.component]
        let make = () => {
          <div className="commit-options">
            {React.string("Commit Options")}
          </div>
        }
      };
      [@react.component]
      let make = (~dropdownActive) => {
        <div className="settings" hidden={!dropdownActive}>
          <CommitMessage />
          <Tags />
          <CommitOptions />
        </div>
      }
    };
    [@react.component]
    let make = () => {
      let (dropdownActive,setDropdownActive) = React.useState(() => true)
      ;
      <header>
        <button className="cancel">
          {React.string("Cancel")}
        </button>
        <button className="save">
          {React.string("Save")}
        </button>
        <button 
          className={"dropdown "++ (dropdownActive?"true":"false")}
          onClick={_=>setDropdownActive(a => !a)}>
          {React.string("Settings")}
        </button>
        <Settings dropdownActive/>
      </header>
    };
  };
  module Toolbar = {
    [@react.component]
    let make = (~seePreview,~setSeePreview) => {
      let _post = PostContext.use();
        
      let handlePreview = () => {
        if (seePreview==false){
          //generate preview
          ();
        };
        setSeePreview(a => !a)
      };
      <div className="toolbar" onClick={_=> handlePreview()}>
        {React.string("Toolbar")}
        <label htmlFor="togglePreviewEditing">{React.string("mode:")}</label>
        <button id="togglePreviewEditing" className={seePreview?"previewing":"editing"}>{React.string(seePreview?"previewing":"editing")}</button>
      </div>
    };
  };
  
  module Preview = {
    [@react.component]
    let make = (~seePreview) => {
      <div className={"preview"} hidden={!seePreview}>
        {React.string("Preview")}
      </div>
    }
  };
  module Editing = {
    module TitleEditing = {
      [@react.component]
      let make = () => {
        <div className="title">
          <label htmlFor="edit-title">{React.string("Title:")}</label>
          <input id="edit-title" type_="text" autoComplete="off"/>
        </div>
      }
    };
    module BodyEditing = {
      [@react.component]
      let make = () => {
        let post = PostContext.use()
        ;
        <div className="body">
          <div className="row-number text-style">
          {
            let list = post.postBody |> String.split_on_char('\n')
            switch(List.length(list)){
              | 0 => [|"1"|]
              | x => Array.init(x-1, i => string_of_int(i + 2))
            }
            |> Array.fold_left((acc,ele) => acc++"\n"++ele,"1")
            |> (x)=> x++"\n."
            |> React.string
          }
          </div>
          <textarea className="body-input text-style" content={post.postBody} onChange={ e => post.setPostBody(React.Event.Form.target(e)##value)}/>
          // <div className="ghost body-input text-style">{React.string(post.postBody++"\n")}</div>
        </div>
      }
    };
    [@react.component]
    let make = (~seePreview) => {
      <div className={"editing"} hidden={seePreview}>
        <TitleEditing/>
        <BodyEditing/>
      </div>
    };
  };
  module Footer = {
    module Error = {
      [@react.component]
      let make = () => {
        <div className="error">
          {React.string("Error")}
        </div>
      }
    };
    module Stats = {
      [@react.component]
      let make = () => {
        <div className="stats"> 
          {React.string("Stats")}
        </div>
      }
    };
    [@react.component]
    let make = () => {
      <footer>
        <Error />
        <Stats />
      </footer>
    };
  };
  [@react.component]
  let make = (~className=?) => {
    let cls = className |> Option.value(~default="")
    let (seePreview,setSeePreview) = React.useState(()=>false)
    ;
    <PostContext.Provider >
      <div className={"only "++cls}>
        <Header />
        <Toolbar seePreview setSeePreview/>
        <Preview seePreview/>
        <Editing seePreview/>
        <Footer />  
      </div>
    </PostContext.Provider >
  }
}
