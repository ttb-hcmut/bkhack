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
          <Tags />
          <CommitMessage />
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
          {React.string("Dropdown")}
        </button>
        <Settings dropdownActive/>
      </header>
    };
  };
  module Toolbar = {
    [@react.component]
    let make = (~setSeePreview) => {
      <div className="toolbar" onClick={_=> setSeePreview(a => !a)}>
        {React.string("Toolbar")}
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
        <div className="body">
          <label htmlFor="edit-body">{React.string("Body:")}</label>
          <textarea id="edit-body"/>
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
    <div className={"only "++cls}>
      <Header />
      <Toolbar setSeePreview/>
      <Preview seePreview/>
      <Editing seePreview/>
      <Footer />
    </div>
  }
}
