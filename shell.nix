{ nixpkgs ? import <nixpkgs> {} }:

let
	pkgs = with nixpkgs; [
		nixd
		dune_3
		pnpm
	];
in
	nixpkgs.mkShell {
		packages = pkgs;
	}

