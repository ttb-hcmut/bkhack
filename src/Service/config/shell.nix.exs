{ nixpkgs ? import <nixpkgs> {} }:

let
	shellHook =
	''
	fly=$(which fly)
	fly() {
		{ cp config/fly.exs _fly_toml && cp config/dockerfile.exs Dockerfile ;} &&
		$fly $@ --config _fly_toml; sts=$?;
		{ rm _fly_toml && rm Dockerfile ;};
		return $sts;
	}
	alias iex='iex --erl "-kernel shell_history enabled"'
	'';
	pkgs = with nixpkgs; [
		nixd
		sqlite
		flyctl
		beamMinimalPackages.elixir
		beamMinimalPackages.livebook
	];
in
	nixpkgs.mkShell {
		packages = pkgs;
		shellHook = shellHook;
	}
# vi: set ft=nix:
