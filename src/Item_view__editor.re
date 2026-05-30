open Auth;

module PostContext = {
  type t = {
    postBody          : string
  , setPostBody       : string => unit
  , error             : string
  , setError          : string => unit
  , postTitle         : string
  , setPostTitle      : string => unit
  , commitMessage     : string
  , setCommitMessage  : string => unit
  , tagList           : list(int)
  , setTagList        : int => bool
  , unsetTagList      : int => unit
  , parentId          : int
  , resetToDefault    : unit => unit
  , allTag            : array(Model.TagButTheColorIsAString.t)
  };

  let defaultValue: t = {
    postBody          : ""
  , setPostBody       : (_) => ()
  , error             : ""
  , setError          : (_) => ()
  , postTitle         : ""
  , setPostTitle      : (_) => ()
  , commitMessage     : ""
  , setCommitMessage  : (_) => ()
  , tagList           : []
  , setTagList        : (_) => false
  , unsetTagList      : (_) => ()
  , parentId          : -1
  , resetToDefault    : (_) => ()
  , allTag            : [||]
  };

  let ctx = React.createContext(defaultValue);

  module Provider = {
    [@react.component]
    let make = (~children: React.element, ~title=?,~body=?,~tag=?) => {
      let url = ReasonReactRouter.useUrl()
      let (postBody,setPostBody) = React.useState( () => "");
      let (postTitle,setPostTitle) = React.useState( () => "");
      let (error,setError) = React.useState( () => "");
      let (commitMessage,setCommitMessage) = React.useState( () => "");
      let (tagList,setTagList') = React.useState(()=>[]);
      let (allTag, setAllTag) = React.useState(()=>[||])

      let parentId = React.useMemo0(()=>{
        String.concat("/",url.path) == "new"? 
        -1 
        :
        url.search
        -> Util.parseQueryParams
        -> Js.Dict.get("id")
        -> Option.value(~default = "-1")
        -> int_of_string});
      
      let unsetTagList= (tag_id) =>{
        if (List.mem(tag_id,tagList)){
          setTagList'(_=>List.filter(x => x != tag_id, tagList));
        } else {
          setError(_=> "tag wasn't added");
        };
      }
      
      let setTagList = (tag_id) => {
        if (List.mem(tag_id,tagList)){
          setError(_=> "tag already added");
          false
        } else {
          setTagList'(_=>[tag_id,...tagList]);
          true
        };
      }

      let resetToDefault = () => {
        switch(title,body,tag){
        | (Some(a),Some(b),Some(c)) =>
          setTagList'(_ => c)
          setPostBody(_ => b)
          setPostTitle(_ => a);
        | _ => ();
        }
      }

      let ctxValue: t = {
        postBody          : postBody
      , setPostBody       : (a) => setPostBody(_ => a)
      , postTitle         : postTitle
      , setPostTitle      : (a) => setPostTitle(_ => a)
      , error             : error
      , setError          : (a) => setError(_=>a)
      , commitMessage     : commitMessage
      , setCommitMessage  : (a) => setCommitMessage(_=>a)
      , tagList           : tagList
      , setTagList        : setTagList
      , unsetTagList      : unsetTagList
      , parentId          : parentId
      , resetToDefault    : resetToDefault
      , allTag            : allTag
      };

      React.useEffect4(() => {
        if(String.length(error)>0){setError(_ => "")}
        None
      },(postBody,postTitle,commitMessage,tagList));

      React.useEffect3(()=>{
        switch(title,body,tag){
        | (Some(a),Some(b),Some(c)) =>
          setPostTitle(_ => a)
          setPostBody(_ => b)
          setTagList'(_ => c)
        | _ => ();
        }
        None
      },(title,body,tag))
      React.useEffect0(()=>{
        let open Fetch__syntax;
        Fetch.fetch(Env.backend ++ "/api/tag/list")
        >>= Fetch.Response.json
        >>= Model.Decode.Response.tags
        >!= (_err => {
            Js.log("err");
            return([||])
          })
        >>= (aod => {
          open Model.Tag;
          setAllTag(
            _ => aod
            |> Array.map((d) => 
              { Model.TagButTheColorIsAString.tag_id    : d.tag_id
              , Model.TagButTheColorIsAString.tag_name  : d.tag_name
              , Model.TagButTheColorIsAString.tag_color : d.tag_color |> Util.rgbaIntToHexString
              } 
            )
          )
          Js.Promise.resolve(aod)
        })
        |> ignore;
        None
      })
      let provider = React.Context.provider(ctx);
      React.createElement(provider, {"value": ctxValue, "children": children})
    };
  };

  let use = () => React.useContext(ctx);
};


module App' = {
  module Header = {
    module Settings = {
      module Tags = {
        [@react.component]
        let make = () => {
          let post = PostContext.use()
          let (tagInput,setTagInput)= React.useState(() => "")
          ;
          <div className="tags" id="edit-tags">
            <label>{React.string("Tags:")}</label>
            <ul>
            {
              List.length(post.tagList)>0?
                post.tagList
                |> List.map(a => {
                  (post.allTag->Js.Array.find(~f= t => t.tag_id == a))
                  |> fun
                  | None => React.null
                  | Some(tag) =>
                  <li key={"taglist"++string_of_int(a)}
                  title="Click to remove tag"
                  style={ReactDOM.Style.make(
                    ~color           = tag.tag_color
                  , ~borderColor     = tag.tag_color
                  , ~backgroundColor = "color-mix(in srgb, "++tag.tag_color++", transparent 75%)"
                  , ())}
                  onClick={_=>post.unsetTagList(a)}
                  >
                    {React.string("#"++tag.tag_name)} 
                  </li>
                })
                |> Array.of_list
                |> React.array
              :
                {React.string("There are no tags yet")}
            }
            </ul>
            <input type_="text"
              placeholder="type to search for tags..."
              value=tagInput
              onChange={e => setTagInput(_=>React.Event.Form.target(e)##value)}
            />
              <dialog open_={String.length(tagInput)> 0}>
                <ol>
                  {
                    open Model.TagButTheColorIsAString;
                    post.allTag
                    |> Js.Array.filter(~f=(t)=>
                        t.tag_name
                        -> Js.String.toLowerCase
                        -> Js.String.includes(~search=tagInput->Js.String.toLowerCase)
                      )
                    |> Array.map(listOption=>{
                      <li key={string_of_int(listOption.tag_id)}
                      onClick={_=> if(post.setTagList(listOption.tag_id)) setTagInput(_=>"")}>
                      {React.string(listOption.tag_name)}
                      </li>
                    })
                    |> React.array
                  }
                </ol>
              </dialog>
          </div>
        }
      };
      module CommitMessage = {
        [@react.component]
        let make = () => {
          let post = PostContext.use()
          ;
          <div className="commit-message">
            <label htmlFor="commit-message">{React.string("Commit message:")}</label>
            <input id="commit-message"
              type_="text" 
              autoComplete="off" 
              placeholder="e.g. changed some things..."
              value={post.commitMessage}
              onChange={ e => post.setCommitMessage(React.Event.Form.target(e)##value)}
              />
          </div>
        }
      };
      module CommitOptions = {
        [@react.component]
        let make = () => {
          let post= PostContext.use()
          ;
          post.parentId == -1 ?
          React.null
          :
          <div className="commit-options">
            <label>
              {React.string("Commit options:")}
            </label>
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
      let post = PostContext.use();
      let auth = AuthContext.use();
      let (dropdownActive,setDropdownActive) = React.useState(() => true)
      let validateCommit = () => {
        if(String.length(String.trim(post.postTitle)) == 0){
          post.setError("post title must not be empty");
          false
        } else if(String.length(String.trim(post.postBody)) == 0){
          post.setError("post body must not be empty");
          false
        } else if(String.length(String.trim(post.commitMessage)) == 0){
          post.setError("commit message must not be empty");
          false
        } else {
          true
        }
      }
      let handleSubmit = (~public) => {
        if (!auth.checkAuth()) {
          auth.forceAuth();
        } else if (!validateCommit()) {
          ()
        } else {
          open Fetch__syntax;
          open Js.Json;
          open Json__syntax;
          let body = empty()
          |> "id"             ^^ int    @@ Option.value(auth.getUserId(),~default = 67)
          |> "post-id"        ^^ int    @@ post.parentId
          |> "title"          ^^ string @@ post.postTitle
          |> "body"           ^^ string @@ post.postBody
          |> "commit_message" ^^ string @@ post.commitMessage
          |> "public"         ^^ bool   @@ public
          |> "tag"            ^^ array  @@ (post.tagList|>Array.of_list|>Array.map( a => a|> int))
          |> finish;
          Fetch.fetchWithInit(
            Env.backend ++"/api/post/create",
            Fetch.RequestInit.make(
              ~method_=Post,
              ~body=Fetch.BodyInit.make(Js.Json.stringify(
                body
              )),
              ~headers=Fetch.HeadersInit.make({
                "Content-Type": "application/json"
              }),
              ()
            )
          )
          >>= Fetch.Response.json
          >>= (j => {
            let res = j |> Js.Json.decodeNumber |> Option.value(~default=-1.) |> int_of_float
            if (res == -1) {
              post.setError("post creation failed");
            }
            else {
              Js__dom.Window.Location.href_set("/item/?id="++ string_of_int(res));
            }
            Js.Promise.resolve(j)
          })
          >!= (err => {
              Js.log(err);
              Js.Promise.resolve(Js.Json.null)
            })
          |> ignore;
        }
      }
      ;
      <header>
        <button className="cancel"
        onClick={_=>
          post.resetToDefault()
        }>
          {React.string("Cancel")}
        </button>
        { 
          post.parentId == -1 ?
          <>
          <button className="save"
            onClick = {_ =>
              handleSubmit(~public=false)
            }>
            {React.string("Save as a private post")}
          </button>
          <button className="publish"
            onClick = {_ =>
              handleSubmit(~public=true)
            }>
            {React.string("Publish Post")}
          </button>
          </>
          :
          <button className="publish"
            onClick = {_ =>
              handleSubmit(~public=true)
            }>
            {React.string("Update Post")}
          </button>
        }

        <button 
          className={"dropdown "++ (dropdownActive?"true":"false")}
          onClick={_=>setDropdownActive(a => !a)}>
          {React.string("Settings")}
        </button>
        <Settings dropdownActive/>
      </header>
    };
  };
  [@alert stupid("bao plz fix markdown")]
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
      <div className="toolbar">
        <div className="tip"
        title="Markdown quick ref:
  # Header => h1
  ## Header => h2">{React.string("Markdown editor")}</div>
  // **bold** => bold
  // *italic* => italic
  // `code` => code
  // ```lang => code block
  // [link](url) => hyperlink
        <label htmlFor="togglePreviewEditing">{React.string("mode:")}</label>
        <button id="togglePreviewEditing" 
          className={seePreview?"previewing":"editing"}
          onClick={_=> handlePreview()}
          >
          {React.string(seePreview?"previewing":"editing")}
        </button>
      </div>
    };
  };
  
  module Preview = {
    [@react.component]
    let make = (~seePreview) => {
      let post = PostContext.use()
      let auth = AuthContext.use()
      let make_html_obj : string => Js.t({ .. __html : string }) = [%mel.raw "function (s) { return { __html : s }; }"]
      let show = (x, f) => switch (x) { | Some(info) => f(info) | None => { <> </> } };
		  let (postInfo, setPostInfo) = React.useState(() => None);
      let renderer = React.useMemo0(() => Melange__cmarkit.Cmarkit_html.renderer(~safe=false, ()));
      let art = React.useMemo2(() => {
        open Melange__cmarkit; open Cmarkit;
        postInfo->Option.bind(((_, _, _, text) as postInfo) =>
        try ({
          let skel = text |> Doc.of_string(~strict=false);
          let block = Doc.block(skel) 
          let rec s = { fun
            | Block.Block_Heading((t, _)) => {
              [@warning "-8"] let (level, Inline.Text((textcontent, _))) = Block.Heading.((level(t), inline(t)));
              [(Int.to_string(level), textcontent, textcontent)] }
            | Block.Blocks((xs, _)) => xs |> List.map(s) |> List.flatten
            | _ => []
          };
          let headings = s(block) |> Melange__iter.Iter.of_list;
          Some((postInfo, headings, Melange__cmarkit.Cmarkit_renderer.doc_to_string(renderer, skel)))
        }) {
          | Invalid_argument(msg) => { post.setError("rendering error: '" ++ msg ++ "'"); None}
          | Js.Exn.Error(x) => { post.setError("js error: '" ++ Option.value(~default="", Js.Exn.message(x)) ++ "'"); None}
        })
      }, (renderer, postInfo))
      React.useEffect1(()=>{
        if(seePreview){
          setPostInfo(_=>Some((67, post.postTitle, auth.getUserName(), post.postBody)))
        }
        
        None
      },[|seePreview|]);
      show(art) @@ (((_, _postTitle, _, _) as _postInfo, _headings, article_body)) =>

      <main className="markdown" hidden={!seePreview}>
			  <div dangerouslySetInnerHTML={make_html_obj @@ article_body} />
      </main>
    }
  };
  module Editing = {
    module TitleEditing = {
      [@react.component]
      let make = () => {
        let post = PostContext.use()
        ;
        <div className="title">
          <label htmlFor="edit-title">{React.string("Title:")}</label>
          <input id="edit-title"
            type_="text" 
            autoComplete="off" 
            placeholder="e.g. my amazing post about..."
            value={post.postTitle}
            onChange={ e => post.setPostTitle(React.Event.Form.target(e)##value)}
            />
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
          <textarea className="body-input text-style" 
            value={post.postBody} 
            placeholder="e.g. # details about..."
            onChange={ e => post.setPostBody(React.Event.Form.target(e)##value)}/>
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
    module Stats = {
      [@react.component]
      let make = () => {
        let post = PostContext.use()
        let charCount = post.postBody
                      |> String.length
        let charNoWhiteCount = charCount - (post.postBody
                                          |> Js.String.split(~sep="")
                                          |> Array.fold_left((acc, c) => 
                                            c == " " 
                                          || c == "\t" 
                                          || c == "\n" 
                                          || c == "\r" 
                                            ? acc + 1 : acc, 0));
        let wordCount = post.postBody
                      |> String.trim
                      |> Js.String.splitByRe(~regexp=[%re {|/[ \t\n\r]+/|}])
                      |> Array.fold_left((acc, x) => x == None || x == Some("") ? acc : acc + 1, 0)
        ;
        <div className="stats"> 
          <span className="char">{React.int(charNoWhiteCount)}</span><span className="word">{React.int(wordCount)}</span>
        </div>
      }
    };
    module Error = {
      [@react.component]
      let make = () => {
        let post = PostContext.use()
        ;
        <div className="error" hidden={String.length(post.error) == 0}>
          {React.string("Error: " ++ post.error)}
        </div>
      }
    };
    [@react.component]
    let make = () => {
      <footer>
        <Stats />
        <Error />
      </footer>
    };
  };
  [@react.component]
  let make = (~className=?) => {
    let cls = className |> Option.value(~default="")
    let (seePreview,setSeePreview) = React.useState(()=>false)
    ;
    <div className={"only "++cls}>
      <Header />
      <Toolbar seePreview setSeePreview/>
      <Footer />  
      <Preview seePreview/>
      <Editing seePreview/>
    </div>
  }
};

module App{
  [@react.component]
  let make = (~className=?,~title=?,~body=?,~tag=?) => {
    <PostContext.Provider title=?title body=?body tag=?tag >
    <App' className=?className />
    </PostContext.Provider >
  }
}