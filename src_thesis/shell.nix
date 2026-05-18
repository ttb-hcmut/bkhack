{ nixpkgs ? import <nixpkgs> {} }:
let pkgs = with nixpkgs; [ typst tinymist ];
in nixpkgs.mkShell {
	packages = pkgs;
}
