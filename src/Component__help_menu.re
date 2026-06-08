module type ReactDOM {
  let querySelector : string => option(Dom.element)
  let domElementToObj : Dom.element => Js.t({ .. })
}

module type Window {
  open React
  let add_event_listener: (string, Event.Keyboard.t => unit) => unit
  let remove_event_listener: (string, Event.Keyboard.t => unit) => unit
}

let update_visibility = (module ReactDOM : ReactDOM, showHelp) => {
  let root = ReactDOM.querySelector("#root")->Option.get->ReactDOM.domElementToObj;
  root##"dataset"##"helpVisibility" #= (showHelp ? "visible" : "");
}

let on_escape = (k, e) => {
  let open React;
  let key = e->Event.Keyboard.key;
  switch (key) {
  | "Escape" =>
    e->Event.Keyboard.stopPropagation;
    e->Event.Keyboard.preventDefault;
    k()
  | _ => ()
  }
}

let use_escape = (module Window : Window, f) => {
  let open React;
  let on_escape = useMemo1(() => on_escape(f), [|f|]);
  useEffect1(() => {
    Window.add_event_listener("keydown", on_escape);
    Some(() => {
      Window.remove_event_listener("keydown", on_escape);
    })
  }, [|on_escape|]);
}

open React

let header = () => {
  <header>
    <label className="icon"/>
    <h1 />
    <label className="sub"/>
    <button className="close"><label /></button>
  </header>
};

let section = (title, ls) => Melange__iter.({
  let item = ((cmd, des)) =>
    <article key=cmd>
      <label className="command">{cmd->string}</label>
      <label className="description">{des->string}</label>
    </article>;
  let content = item =>
    <section>
      <h2>{title->string}</h2>
      {ls |> Iter.of_array |> Iter.map(item) |> Iter.to_array |> array}
    </section>;
  () => content(item)
});

let feed_cmds = section("Feed") @@ [|
  ("feed", "fetch all bkhack posts."),
  ("sort [--hot | --latest]", "pagination controls of sort mode."),
  ("split [-c NUM]", "pagination controls of how many items to show per page."),
  ("rg [--title STR | --content STR]", "search by matching string.")
|];

let items_cmds = section("Post") @@ [|
  ("cat ID", "show article content of a post."),
|];

[@react.component]
let make = (~on_click_out) => {
  <dialog className="help" open_=true onClick=on_click_out>
    <div>
      {header()}
      <main>
        {feed_cmds()}
        {items_cmds()}
      </main>
    </div>
  </dialog>
} 
