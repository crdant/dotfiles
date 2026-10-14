# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs ? import <nixpkgs> {} } : 
rec {

  mbta-mcp-server = pkgs.callPackage ./mbta-mcp-server { };
  tunnelmanager = pkgs.callPackage ./tunnelmanager { };

  leftovers = pkgs.callPackage ./leftovers { };

  llmPlugins = pkgs.callPackage ./llm/plugins { };

  icalpal = pkgs.callPackage ./icalpal { };
  mole = pkgs.callPackage ./mole { };

  zapier-platform-cli = pkgs.callPackage ./zapier-platform-cli { };
  spiral-cli = pkgs.callPackage ./spiral-cli { };
  readwise-cli = pkgs.callPackage ./readwise-cli { };
  hermes-agent = pkgs.callPackage ./hermes-agent { };
  vault-gardener = pkgs.callPackage ./vault-gardener { };
  space-grotesk = pkgs.callPackage ./space-grotesk { };

  kubectl-refresh-config = pkgs.callPackage ./kubectl-refresh-config { };

  flac2aac = pkgs.callPackage ./flac2aac { };
  shn2aac = pkgs.callPackage ./shn2aac { };

  # simonw tools
  claude-code-transcripts = pkgs.callPackage ./claude-code-transcripts { };
  ttok = pkgs.callPackage ./ttok { };
  rodney = pkgs.callPackage ./rodney { };
  showboat = pkgs.callPackage ./showboat { };
}
