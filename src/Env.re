let%comptime backend = Option.value(~default="http://idea:5000") @@ Sys.getenv_opt("BKHACK_BACKEND_ADDRESS")

module Firebase {
	let key = "AIzaSyAGZ7O5DJBt3_lcEsrJBQn_HF3e4D59X1A"
}
