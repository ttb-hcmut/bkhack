{ nixpkgs ? import <nixpkgs> {} }:

let
	pkgs = with nixpkgs; [
		nixd
		sqlite
		beamMinimalPackages.elixir
		beamMinimalPackages.livebook
	];
in
	nixpkgs.mkShell {
		packages = pkgs;
		shellHook = ''
			alias iex='iex --erl "-kernel shell_history enabled"'
		'';
	}

