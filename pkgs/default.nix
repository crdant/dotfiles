# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs ? import <nixpkgs> {} } : rec {

  vimr = pkgs.callPackage ./vimr { };
  tunnelmanager = pkgs.callPackage ./tunnelmanager { };

  replicated = pkgs.callPackage ./replicated { };
  kots = pkgs.callPackage ./kots { };
  troubleshoot-sbctl = pkgs.callPackage ./sbctl { };

  mods = pkgs.callPackage ./mods { };
}
