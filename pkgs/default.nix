# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs ? import <nixpkgs> {} } : rec {

  mbta-mcp-server = pkgs.callPackage ./mbta-mcp-server { };
  tunnelmanager = pkgs.callPackage ./tunnelmanager { };

  vimr = pkgs.callPackage ./vimr { };

  replicated = pkgs.callPackage ./replicated { };
  kots = pkgs.callPackage ./kots { };
  troubleshoot-sbctl = pkgs.callPackage ./sbctl { };

  # llm-mlx = pkgs.callPackage ./llm-mlx { };
  # llm-anthropic = pkgs.callPackage ./llm-anthropic { };
  # llm-perplexity = pkgs.callPackage ./llm-perplexity { };
  # llm-gemini = pkgs.callPackage ./llm-gemini { }; 

  instruqt = pkgs.callPackage ./instruqt { };

  imgpkg = pkgs.callPackage ./imgpkg { };
}
