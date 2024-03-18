# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs ? import <nixpkgs> {} } : rec {
  vimr = pkgs.callPackage ./vimr { };
  replicated = pkgs.callPackage ./replicated { };
  kots = pkgs.callPackage ./kots { };
  mods = pkgs.callPackage ./mods { };
}
