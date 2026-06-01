{ nixpkgs ? import <nixpkgs> {} }:

let shellHook =
	''
	firebase=$(which firebase)
	firebase() {
		cp build_aux/firebase.json __firebase_json &&
		$firebase --config __firebase_json $@;
		sts=$?;
		rm __firebase_json;
		return $sts;
	}
	'';
	pkgs = with nixpkgs; [
		elixir erlang
		pnpm nodejs
		nixd
		opam rsync
		
		gnugrep
		procps
	];
in
	nixpkgs.mkShell {
		packages = pkgs;
		shellHook = shellHook;
	}

