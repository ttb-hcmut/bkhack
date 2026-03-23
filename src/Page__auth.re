[@Bkhack.page "/auth"]
// open Melange__containers.Fun

let parseQueryParams = (search: string): Js.Dict.t<string> => {
    let params = Js.Dict.empty();
    Js.String.split(~sep="&", search)
    |> Js.Array.forEach(~f = pair => {
        let parts = Js.String.split(~sep="=", pair);
            if (Js.Array.length(parts) == 2) {
                let key = Js.Array.unsafe_get(parts, 0) |> Js.Global.decodeURIComponent;
                let value = Js.Array.unsafe_get(parts, 1) |> Js.Global.decodeURIComponent;
                Js.Dict.set(params, key, value);
            }
        }
    );
    params
};
// x |> f(a) |> g(b)
// g(b,f(a,x))

// x ||> f(a) ||> g(b)
// g(b,f(a,x))

// x -> f(a) -> g(b)
// g(f(x,a),b)

// x %> f(a) %> g(b)
// g(f(x,a),b)

module Login = {
	[@react.component]
	let make = () => {
        let (errorMsg,setErrorMsg)=React.useState(_ => "");

        let (formUsername, setFormUsername) = React.useState(_ => "");
        let (formPassword, setFormPassword) = React.useState(_ => "");


        let handleSubmit = e => {
            let _ = Obj.magic(e)##preventDefault();
            if (String.length(formUsername) <= 0)
            {
                setErrorMsg(_ => "username field empty");
            }
            else if (String.length(formPassword) < 8)
            {
                setErrorMsg(_ => "password is less than 8 characters long");
            }
            else
            {
                //TODO: actually send data to back end
                setErrorMsg(_ => "");
                Js.log("Sending form data:");
                Js.log("username: " ++ formUsername);   
                Js.log("password: " ++ formPassword);
            }
        };
        <>
        <main className="login">
            <form>
                <label htmlFor="username">{React.string("username:")}</label>
                <input type_="username" id="username" placeholder="mrbombastic . . ."
                value=formUsername onChange={e => setFormUsername(_ => Obj.magic(e)##target##value)}/>
                <label htmlFor="password">{React.string("password:")}</label>
                <input type_="password" id="password" placeholder="tellmefantastic . . ."
                value=formPassword onChange={e => setFormPassword(_ => Obj.magic(e)##target##value)}/>
                
                <div className="error" hidden={String.length(errorMsg)==0}>
                    <b>{React.string("ERROR:")}</b>
                    <p>{React.string(errorMsg)}</p>
                </div>
                
                <button type_="submit" onClick=handleSubmit>{React.string("log in")}</button>
            </form>
            <span/>
            <a href="?action=forgot">{React.string("forgot password?")}</a>
            <a href="?action=register">{React.string("register an account?")}</a>

        </main>
        </>

    }
}

module Register = {
    include Js.Re
	[@react.component]
	let make = () => {
        let (errorMsg,setErrorMsg)=React.useState(_ => "");

        let (formEmail, setFormEmail) = React.useState(_ => "");
        let (formUsername, setFormUsername) = React.useState(_ => "");
        let (formPassword, setFormPassword) = React.useState(_ => "");

        React.useEffect0(() => {
            None
		});

        let emailish = Js.Re.test(~str = formEmail,Js.Re.fromString("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"))?"":"invalid";
        let namefull = String.length(formUsername) > 0 ? "" : "invalid";
        let namechar = Js.Re.test(~str = formUsername,Js.Re.fromString("^[a-z0-9]*$"))?"":"invalid";
        let passlong = String.length(formPassword) >= 8 ? "" : "invalid";

        let handleSubmit = e => {
            let _ = Obj.magic(e)##preventDefault();
            if (emailish != "" || namefull != "" || namechar != "" || passlong != "")
            {
                setErrorMsg(_ => "please fulfill the requirements highlighted in red");
            }
            else
            {
                //TODO: actually send data to back end
                setErrorMsg(_ => "");
                Js.log("Sending form data:");
                Js.log("email: " ++ formEmail);   
                Js.log("username: " ++ formUsername);   
                Js.log("password: " ++ formPassword);
            }
        };
        <>
        <main className="register">
            <form>
                <label htmlFor="email">{React.string("email:")}</label>
                <input type_="email" id="email" placeholder="em@in.em . . ."
                value=formEmail onChange={e => setFormEmail(_ => Obj.magic(e)##target##value)}/>
                
                <label htmlFor="username">{React.string("username:")}</label>
                <input type_="username" id="username" placeholder="mynameiseminem . . ."
                value=formUsername onChange={e => setFormUsername(_ => Obj.magic(e)##target##value)}/>
        
                <label htmlFor="password">{React.string("password:")}</label>
                <input type_="password" id="password" placeholder="somethinghardtoguess . . ."
                value=formPassword onChange={e => setFormPassword(_ => Obj.magic(e)##target##value)}/>
                
                <ul>
                    <li className={emailish}>{React.string("-")} <span>{React.string(" ")}</span> {React.string("email must be valid")}</li>
                    <li className={namefull}>{React.string("-")} <span>{React.string(" ")}</span> {React.string("username must not be empty")}</li>
                    <li className={namechar}>{React.string("-")} <span>{React.string(" ")}</span> {React.string("username must contain only lowercase letters a-z or numbers 0-9")}</li>
                    <li                     >{React.string("-")} <span>{React.string(" ")}</span> {React.string("username must be unique")}</li>
                    <li className={passlong}>{React.string("-")} <span>{React.string(" ")}</span> {React.string("password must be 8 characters or longer")}</li>
                </ul>

                <div className="error" hidden={String.length(errorMsg)==0}>
                    <b>{React.string("ERROR:")}</b>
                    <p>{React.string(errorMsg)}</p>
                </div>
                
                <button type_="submit" onClick=handleSubmit>{React.string("register account")}</button>
            </form>
            <span/>
            <a href="?action=login">{React.string("already have an account?")}</a>

        </main>
        </>

    }
}

module Countdown = {
  [@val] external setInterval: (unit => unit, int) => float = "setInterval";
  [@val] external clearInterval: float => unit = "clearInterval";

  let start = (~setCount, ()) => {
    let id = ref(0.0);
    id := setInterval(() => {
      setCount(c => {
        if (c <= 1) {
          clearInterval(id^);
          0;
        } else {
          c - 1;
        };
      });
    }, 1000);

    () => clearInterval(id^);
  };
};
module Forgot = {
	[@react.component]
	let make = () => {
        
        let (errorMsg,setErrorMsg)=React.useState(_ => "");
        
        let (timeleft,setTimeleft)=React.useState(_ => 0);
        let timeleftCleanup = React.useRef(() => ());

        let (formEmail, setFormEmail) = React.useState(_ => "");
        let (formCode, setFormCode) = React.useState(_ => "");
        
        let emailish = Js.Re.test(~str = formEmail,Js.Re.fromString("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"));
        
        let sendCode = e => {
            let _ = Obj.magic(e)##preventDefault();
            switch (emailish,timeleft==0) {
                | (false,_) => setErrorMsg(_=>"invalid email")
                | (_,false) => setErrorMsg(_=>"please wait before resending the code")
                | (true,true) =>
                    setErrorMsg(_=>"");
                    Js.log("sent code to email "++ formEmail);
                    setTimeleft(_=>30);
                    timeleftCleanup.current = Countdown.start(~setCount=setTimeleft, ());

            }
        };
        
        let handleSubmit= _ => {
            Js.log("submitting: ");
            Js.log(formEmail);
            Js.log(formCode);
        };

        React.useEffect1(() => {
        if (String.length(formCode) == 6) {
            handleSubmit();
        };
        None;
        }, [|formCode|]);

        <>
        <main className="forgot">
            <form>
                <label htmlFor="email">{React.string("email:")}</label>
                <input type_="email" id="email" placeholder="em@in.em . . ."
                value=formEmail onChange={e => setFormEmail(_ => Obj.magic(e)##target##value)}
                disabled={timeleft!=0}/>
                
                <div className="error" hidden={String.length(errorMsg)==0}>
                    <b>{React.string("ERROR:")}</b>
                    <p>{React.string(errorMsg)}</p>
                </div>
                
                <button type_="submit" onClick=sendCode
                disabled={timeleft!=0}>
                    {
                        switch (timeleft){
                            | 0 => React.string("send code");
                            | a => React.string(string_of_int(a) ++ " second(s) until code can be resent" )
                        }
                        
                    }
                </button>
            </form>
            {
                timeleft==0?
                React.null
                :
                <form onSubmit={
                    e => {
                        let _ = Obj.magic(e)##preventDefault();
                        ();
                    }}>
                    <label htmlFor="code">{React.string("code:")}</label>
                    <input type_="password" inputMode="numeric" maxLength=6 id="code" placeholder="check the above email for a code"
                    value=formCode onChange={e => {
                        let value: string = Obj.magic(e)##target##value;
                        if (Js.Re.test(Js.Re.fromString("^[0-9]{0,6}$"),~str= value)) {
                            setFormCode(_ => value);
                        };
                    }}/>
                    
                </form>
            }
            <span/>
            <a href="?action=login">{React.string("remembered password?")}</a>

        </main>
        </>

    }
}


module App = {
	[@react.component]
	let make = () => {
        let search = ReasonReactRouter.useUrl().search;
        let params = parseQueryParams(search);

        // Get a specific param
        let action = switch (Js.Dict.get(params, "action")) {
            | Some(id) => id
            | None => "login"
            }; // option<string>
		<>
            <a className="logo" href="/" />
            <p>{React.string("$ ssh user@bkhack.wiki")}</p>
            {
                switch (action) {
                    | "login" => <Login/>
                    | "register" => <Register/>
                    | "forgot" => <Forgot/>
                    | _ => <Login/>
                } 
            }
        // <div className="footer">
        //     {React.string("Copyright 696969")}
        // </div>
		</>
        
	}
}

module ReactDOM0 = {
	let querySelector = x =>
		switch (ReactDOM.querySelector(x)) {
		| Some(x) => x
		| None =>
			Js.Console.error("khong tim thay element #root");
			failwith("lol")
		}
}

let element = ReactDOM0.querySelector("#root");
let root = ReactDOM.Client.createRoot(element);
ReactDOM.Client.render(root, <App />);
