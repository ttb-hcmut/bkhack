{ nixpkgs ? import <nixpkgs> {}
, withDocs ? true
}:

let
  docs = import ./docs.nix { inherit nixpkgs; };

  shellHook = ''
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
	rm -rf _build/.webpacking
	export DUNE_BUILD_DIR=$PWD/_build
	dune exec src/webpackgen2.exe -- --in=$DUNE_BUILD_DIR/.webpacking/in --out=$DUNE_BUILD_DIR/.webpacking/out >&_webpackgen2.log &
  '';
	pkgs = with nixpkgs; [
		zstd
		elixir erlang
		pnpm nodejs
		nixd haskell-language-server
		opam rsync
		gnugrep
		procps
		ruby
	]
	++ nixpkgs.lib.optionals withDocs docs.packages;
in
	nixpkgs.mkShell {
		packages = pkgs;
		shellHook = 
		  shellHook
		  + nixpkgs.lib.optionalString withDocs docs.shellHook;
	}