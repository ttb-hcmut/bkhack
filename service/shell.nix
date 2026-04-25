{ nixpkgs ? import <nixpkgs> {} }:

let
	pkgs = with nixpkgs; [
		nixd
		sqlite
		beamMinimalPackages.elixir
	];
in
	nixpkgs.mkShell {
		packages = pkgs;
		shellHook = ''
			alias iex='iex --erl "-kernel shell_history enabled"'
		'';
	}

