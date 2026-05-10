[@Bkhack.page "/auth"]

open Auth

module Login = {
	[@react.component]
	let make = (~setAction) => {
		let (errorMsg,setErrorMsg) = React.useState(_ => "");
    let url = ReasonReactRouter.useUrl()
		let (formUsername, setFormUsername) = React.useState(_ => "");
		let (formPassword, setFormPassword) = React.useState(_ => "");

    let auth = AuthContext.use();
		let handleSubmit =(event) => {
			React.Event.Synthetic.preventDefault(event);
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
        let open Js.Json;
        let body = Json__syntax.( empty()
        |> "username" ^^ string @@ formUsername
        |> "password" ^^ string @@ formPassword
        |> finish );
        open Fetch__syntax;
        Fetch.fetchWithInit(
          Env.backend ++"/api/auth/login",
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
        >!= (err => {
          Js.log(err);
          auth.unsetAuth();
          Js.Promise.reject(Js.Exn.anyToExnInternal @@ err)
        })
        >>= Fetch.Response.json
        >>= Model.Decode.Response.fetchedAuth
        >>= (j => {
          open Model.FetchedAuth;
          auth.setAuth(j.user_id,j.name);
          url.search
          -> Util.parseQueryParams
          -> Js.Dict.get("redirect")
          -> Option.value(~default = Js.Global.encodeURI("/"))
          -> Js.Global.decodeURI
          -> Js__dom.Window.Location.href_set
          -> ignore;
          Js.Promise.resolve(j)
        }) |> ignore
			}
		};
		<main className="login">
			<form>
				<label htmlFor="username">{React.string("username:")}</label>
				<input type_="username" id="username" placeholder="mrbombastic . . ."
				value=formUsername onChange={e => setFormUsername(_ => React.Event.Form.target(e)##value)}/>
				<label htmlFor="password">{React.string("password:")}</label>
				<input type_="password" id="password" placeholder="tellmefantastic . . ."
				value=formPassword onChange={e => setFormPassword(_ => React.Event.Form.target(e)##value)}/>
				
				<div className="error" hidden={String.length(errorMsg)==0}>
					<b>{React.string("ERROR:")}</b>
					<p>{React.string(errorMsg)}</p>
				</div>
				
				<button type_="submit" onClick=handleSubmit>{React.string("log in")}</button>
			</form>
			<span/>
			<a onClick={_ => setAction(_ => "forgot")}>{React.string("forgot password?")}</a>
			<a onClick={_ => setAction(_ => "register")}>{React.string("register an account?")}</a>

		</main>
	}
}

module Register = {
	[@react.component]
	let make = (~setAction) => {
		let (errorMsg,setErrorMsg)=React.useState(_ => "");

		let (formEmail, setFormEmail) = React.useState(_ => "");
		let (formUsername, setFormUsername) = React.useState(_ => "");
		let (formPassword, setFormPassword) = React.useState(_ => "");
		let (formRePassword, setFormRePassword) = React.useState(_ => "");

		React.useEffect0(() => {
				None
		});

		let emailish = Js.Re.test(~str = formEmail,Js.Re.fromString("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"))?"":"invalid";
		let namefull = String.length(formUsername) > 0 ? "" : "invalid";
		let namechar = Js.Re.test(~str = formUsername,Js.Re.fromString("^[a-z0-9]*$"))?"":"invalid";
		let passlong = String.length(formPassword) >= 8 ? "" : "invalid";
		let repasseq = formPassword == formRePassword? "" : "invalid"

		let handleSubmit =(event) => {
			React.Event.Synthetic.preventDefault(event);
			if (emailish != "" || namefull != "" || namechar != "" || passlong != ""|| repasseq != "")
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
		<main className="register">
			<form>
				<label htmlFor="email">{React.string("email:")}</label>
				<input type_="email" id="email" placeholder="em@in.em . . ."
				value=formEmail onChange={e => setFormEmail(_ =>React.Event.Form.target(e)##value)}/>
				
				<label htmlFor="username">{React.string("username:")}</label>
				<input type_="username" id="username" placeholder="mynameiseminem . . ."
				value=formUsername onChange={e => setFormUsername(_ => React.Event.Form.target(e)##value)}/>

				<label htmlFor="password">{React.string("password:")}</label>
				<input type_="password" id="password" placeholder="somethinghardtoguess . . ."
				value=formPassword onChange={e => setFormPassword(_ => React.Event.Form.target(e)##value)}/>

				<label htmlFor="repassword">{React.string("retype password:")}</label>
				<input type_="password" id="repassword" placeholder="somethinghardtoguess . . ."
				value=formRePassword onChange={e => setFormRePassword(_ => React.Event.Form.target(e)##value)}/>
				
				<ul>
					<li className={emailish}>{React.string("-")} <span>{React.string(" ")}</span> {React.string("email must be valid")}</li>
					<li className={namefull}>{React.string("-")} <span>{React.string(" ")}</span> {React.string("username must not be empty")}</li>
					<li className={namechar}>{React.string("-")} <span>{React.string(" ")}</span> {React.string("username must contain only lowercase letters a-z or numbers 0-9")}</li>
					<li                     >{React.string("-")} <span>{React.string(" ")}</span> {React.string("username must be unique")}</li>
					<li className={passlong}>{React.string("-")} <span>{React.string(" ")}</span> {React.string("password must be 8 characters or longer")}</li>
					<li className={repasseq}>{React.string("-")} <span>{React.string(" ")}</span> {React.string("retyped password must match password")}</li>
				</ul>

				<div className="error" hidden={String.length(errorMsg)==0}>
					<b>{React.string("ERROR:")}</b>
					<p>{React.string(errorMsg)}</p>
				</div>
				
				<button type_="submit" onClick=handleSubmit>{React.string("register account")}</button>
			</form>
			<span/>
			<a onClick={_ => setAction(_ => "login")}>{React.string("already have an account?")}</a>

		</main>
	}
}

module Countdown = { 
	let start = (~setCount,~id:React.ref(option(Js.Global.intervalId)),()) => {
		id.current = Some(Js.Global.setInterval(~f = () => {
			setCount(c => {
				if (c <= 1) {
					switch(id.current){
						| Some(intervalId) => Js.Global.clearInterval(intervalId)
						| _ => ()
					};
					0;
				} else {
					c - 1;
				};
			});
		}, 1000));

		switch(id.current){
			| Some(intervalId) =>
				() => Js.Global.clearInterval(intervalId)
			| _ => () => ()
		};
	};
};

module Forgot = {
	[@react.component]
	let make = (~setAction) => {
		let (errorMsg,setErrorMsg) = React.useState(_ => "");
		
		let id = React.useRef(None);
		let (timeleft,setTimeleft) = React.useState(_ => 0);
		let timeleftCleanup = React.useRef(() => ());

		let (formEmail, setFormEmail) = React.useState(_ => "");
		let (formCode, setFormCode) = React.useState(_ => "");
		
		let emailish = Js.Re.test(~str = formEmail, Js.Re.fromString("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"));
		
		let sendCode = (event) => {
			React.Event.Synthetic.preventDefault(event);
			switch (emailish,timeleft==0) {
				| (false,_) => setErrorMsg(_=>"invalid email")
				| (_,false) => setErrorMsg(_=>"please wait before resending the code")
				| (true,true) =>
					setErrorMsg(_=>"");
					Js.log("sent code to email "++ formEmail);
					setTimeleft(_ => 30);
					timeleftCleanup.current = Countdown.start(~setCount = setTimeleft,~id = id,());
			}
		};
		
		let handleSubmit= _ => {
			Js.log("submitting: ");
			Js.log(formEmail);
			Js.log(formCode);
			ReasonReactRouter.push("?action=reset&ticket=6969");
		};

		React.useEffect1(() => {
			if (String.length(formCode) == 6) {
				handleSubmit();
			};
			None;
		}, [|formCode|]);
		<main className="forgot">
			<form>
				<label htmlFor="email">{React.string("email:")}</label>
				<input type_="email" id="email" placeholder="em@in.em . . ."
				value=formEmail onChange={e => setFormEmail(_ => React.Event.Form.target(e)##value)}
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
				<form autoComplete="off" onSubmit={
					event => {
						React.Event.Synthetic.preventDefault(event);
					}}>
					<label htmlFor="code">{React.string("code:")}</label>
					<input type_="password" autoComplete="new-password" inputMode="numeric" maxLength=6 id="code" placeholder="check the above email for a code"
					value=formCode onChange={e => {
						let value: string = React.Event.Form.target(e)##value;
						if (Js.Re.test(Js.Re.fromString("^[0-9]{0,6}$"),~str= value)) {
								setFormCode(_ => value);
						};
					}}/>
						
				</form>
			}
			<span/>
			<a onClick={_ => setAction(_ => "login")}>{React.string("remembered password?")}</a>
		</main>
	}
}

module Reset = {
	[@react.component]
	let make = (~setAction) => {
		let (errorMsg,setErrorMsg) = React.useState(_ => "");

		let (formPassword, setFormPassword) = React.useState(_ => "");
		let (formRePassword, setFormRePassword) = React.useState(_ => "");

		let ticketParam = ReasonReactRouter.useUrl().search 
		let resetTicket = React.useRef("");

		React.useEffect0(() => {
			switch( ticketParam
					-> Util.parseQueryParams
					-> Js.Dict.get("ticket") )
			{
				| Some(ticket) => resetTicket.current = ticket
				| None => resetTicket.current = ""
				// TODO(khang): maybe redirect to login page if no ticket or invalid ticket instead
			}
			None
		});

		let passlong = String.length(formPassword) >= 8 ? "" : "invalid";
		let repasseq = formPassword == formRePassword? "" : "invalid"

		let handleSubmit = (event) => {
			React.Event.Synthetic.preventDefault(event);
			if (passlong != ""|| repasseq != "")
			{
				setErrorMsg(_ => "please fulfill the requirements highlighted in red");
			}
			else
			{
				// TODO(khang): actually send data to back end
				setErrorMsg(_ => "");
				Js.log("Sending form data:");
				Js.log("password: " ++ formPassword);
				Js.log("resetTicket: " ++ resetTicket.current);
				ReasonReactRouter.push("?login");
			}
		};
		<main className="register">
			<form>
				<label htmlFor="password">{React.string("password:")}</label>
				<input type_="password" id="password" placeholder="somethinghardtoguess . . ."
				value=formPassword onChange={e => setFormPassword(_ => React.Event.Form.target(e)##value)}/>

				<label htmlFor="repassword">{React.string("retype password:")}</label>
				<input type_="password" id="repassword" placeholder="somethinghardtoguess . . ."
				value=formRePassword onChange={e => setFormRePassword(_ => React.Event.Form.target(e)##value)}/>
				
				<ul>
					<li className={passlong}>{React.string("-")} <span>{React.string(" ")}</span> {React.string("password must be 8 characters or longer")}</li>
					<li className={repasseq}>{React.string("-")} <span>{React.string(" ")}</span> {React.string("retyped password must match password")}</li>
				</ul>

				<div className="error" hidden={String.length(errorMsg)==0}>
					<b>{React.string("ERROR:")}</b>
					<p>{React.string(errorMsg)}</p>
				</div>
				
				<button type_="submit" onClick=handleSubmit>{React.string("reset password")}</button>
			</form>
			<span/>
			<a onClick={_ => setAction(_ => "login")}>{React.string("already have an account?")}</a>
		</main>
    }
}

module App = {
	[@react.component]
	let make = () => {
		let url = ReasonReactRouter.useUrl();
		let search = url.search;
		let params = Util.parseQueryParams(search)
		and params' = Util.parseQueryParams'(search);
		let (action, setAction) = React.useState(() =>
			switch (Js.Dict.get(params, "action")) {
				| Some(id) => id
				| None => "login"
			});
		let setAction = React.useCallback1(make => {
			setAction(prev => {
				let verb = make(prev);
				ReasonReactRouter.push(String.concat("/", ["", ...url.path]) ++ {
					"/?" ++ ( params' |> Util.List.replace_assoc'("action", verb) |> Util.stringQueryParams' )
				});
				verb
			});
		}, [|setAction|]);
    <AuthContext.Provider>
      <a className="logo" href="/" />
      <p><span className="command">{React.string("ssh user@bkhack.wiki")}</span></p>
      {
        switch (action) {
          | "login" => <Login key="login" setAction />
          | "register" => <Register key="register" setAction />
          | "forgot" => <Forgot key="forgot" setAction />
          | "reset" => <Reset key="reset" setAction />
          | _ => <Login key="login" setAction />
        } 
      }
    </AuthContext.Provider>
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

let () = {
	let element = ReactDOM0.querySelector("#root");
	let root = ReactDOM.Client.createRoot(element);
	ReactDOM.Client.render(root, <App />)
}
