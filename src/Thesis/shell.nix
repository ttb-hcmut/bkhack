{ nixpkgs ? import <nixpkgs> {} }:

let
  docs = import ../../build_aux/docs.nix { inherit nixpkgs; };
in
nixpkgs.mkShell {
  inherit (docs) packages shellHook;
}