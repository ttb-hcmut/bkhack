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
  pnpm=$(which pnpm)
  pnpm() {
    { ln --symbolic --force build_aux/package.json package.json && ln --symbolic --force build_aux/pnpm-lock.yaml pnpm-lock.yaml ;} &&
    $pnpm $@;
    sts=$?;
    # { rm package.json && rm pnpm-lock.yaml ;};
    return $sts;
  }
	'';
	pkgs = with nixpkgs; [
		elixir erlang
		pnpm nodejs
		nixd haskell-language-server
		opam rsync
		tinymist
		gnugrep
		procps
		ruby
	];
in
	nixpkgs.mkShell {
		packages = pkgs;
		shellHook = shellHook;
	}

