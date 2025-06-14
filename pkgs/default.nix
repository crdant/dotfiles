# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs ? import <nixpkgs> {} } : 
rec {

  mbta-mcp-server = pkgs.callPackage ./mbta-mcp-server { };
  tunnelmanager = pkgs.callPackage ./tunnelmanager { };

  vimr = pkgs.callPackage ./vimr { };
  leftovers = pkgs.callPackage ./leftovers { };

  replicated = pkgs.callPackage ./replicated { };
  kots = pkgs.callPackage ./kots { };
  troubleshoot-sbctl = pkgs.callPackage ./sbctl { };

  llmPlugins = pkgs.callPackage ./llm/plugins { };

  instruqt = pkgs.callPackage ./instruqt { };

  imgpkg = pkgs.callPackage ./imgpkg { };
}
