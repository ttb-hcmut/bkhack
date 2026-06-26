{ nixpkgs ? import <nixpkgs> {} }:

{
  packages = with nixpkgs; [
    typst
    tinymist
    fontconfig
  ];

  shellHook = ''
    export FONTCONFIG_FILE=${../src/thesis/fonts.conf}
  '';
}