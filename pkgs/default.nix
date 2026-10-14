# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs ? import <nixpkgs> {}, inputs ? {} } : 
rec {

  mbta-mcp-server = pkgs.callPackage ./mbta-mcp-server { };
  tunnelmanager = pkgs.callPackage ./tunnelmanager { };

  leftovers = pkgs.callPackage ./leftovers { };

  llmPlugins = pkgs.callPackage ./llm/plugins { };

  icalpal = pkgs.callPackage ./icalpal { };
  mole = pkgs.callPackage ./mole { };

  readwise-cli = pkgs.callPackage ./readwise-cli { };
  space-grotesk = pkgs.callPackage ./space-grotesk { };

  kubectl-refresh-config = pkgs.callPackage ./kubectl-refresh-config { };

  flac2aac = pkgs.callPackage ./flac2aac { };
  shn2aac = pkgs.callPackage ./shn2aac { };

  # simonw tools, locked with uv (see ./simonw-tools); needs the uv2nix
  # flake inputs, so only available through the flake
  inherit (import ./simonw-tools { inherit pkgs inputs; })
    claude-code-transcripts ttok rodney showboat;
  # Needs Playwright >= 1.62, which stable nixpkgs doesn't have yet
  shot-scraper = pkgs.unstable.callPackage ./shot-scraper { };
}
