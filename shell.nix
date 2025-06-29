{ nixpkgs ? import <nixpkgs> {} }:

let
	pkgs = with nixpkgs; [
		nixd
		dune_3
		pnpm
		opam
		nodejs
	];
in
	nixpkgs.mkShell {
		packages = pkgs;
	}

