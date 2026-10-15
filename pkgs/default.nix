# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs ? import <nixpkgs> {} } : 
rec {

  mbta-mcp-server = pkgs.callPackage ./mbta-mcp-server { };
  tunnelmanager = pkgs.callPackage ./tunnelmanager { };

  leftovers = pkgs.callPackage ./leftovers { };

  llmPlugins = pkgs.callPackage ./llm/plugins { };

  icalpal = pkgs.callPackage ./icalpal { };

  readwise-cli = pkgs.callPackage ./readwise-cli { };
  space-grotesk = pkgs.callPackage ./space-grotesk { };

  kubectl-refresh-config = pkgs.callPackage ./kubectl-refresh-config { };

  flac2aac = pkgs.callPackage ./flac2aac { };
  shn2aac = pkgs.callPackage ./shn2aac { };

  # simonw tools
  claude-code-transcripts = pkgs.callPackage ./claude-code-transcripts { };
  ttok = pkgs.callPackage ./ttok { };
  rodney = pkgs.callPackage ./rodney { };
  showboat = pkgs.callPackage ./showboat { };
  # Needs Playwright >= 1.62, which stable nixpkgs doesn't have yet
  shot-scraper = pkgs.unstable.callPackage ./shot-scraper { };
}
