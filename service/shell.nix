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
	}

