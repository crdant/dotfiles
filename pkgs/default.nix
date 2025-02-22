# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs ? import <nixpkgs> {} } : rec {

  vimr = pkgs.callPackage ./vimr { };
  tunnelmanager = pkgs.callPackage ./tunnelmanager { };

  replicated = pkgs.callPackage ./replicated { };
  kots = pkgs.callPackage ./kots { };
  kots2helm = pkgs.callPackage ./kots2helm { };
  troubleshoot-sbctl = pkgs.callPackage ./sbctl { };

  # llm-mlx = pkgs.callPackage ./llm-mlx { };
  # llm-anthropic = pkgs.callPackage ./llm-anthropic { };
  # llm-perplexity = pkgs.callPackage ./llm-perplexity { };
  # llm-gemini = pkgs.callPackage ./llm-gemini { }; 

  instruqt = pkgs.callPackage ./instruqt { };
  mods = pkgs.callPackage ./mods { };

  imgpkg = pkgs.callPackage ./imgpkg { };

  iterm-ai = pkgs.callPackage ./iterm-ai { };

}
