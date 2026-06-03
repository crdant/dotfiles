# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs ? import <nixpkgs> {} }:
let
  inherit (pkgs) lib;
in
{
  mbta-mcp-server = pkgs.callPackage ./mbta-mcp-server {};
  tunnelmanager = pkgs.callPackage ./tunnelmanager {};

  leftovers = pkgs.callPackage ./leftovers {};

  replicated = pkgs.callPackage ./replicated {};
  kots = pkgs.callPackage ./kots {};
  troubleshoot-sbctl = pkgs.callPackage ./sbctl {};
  helm-beta = pkgs.callPackage ./helm-beta {};

  instruqt = pkgs.callPackage ./instruqt {};
  imgpkg = pkgs.callPackage ./imgpkg {};

  mole = pkgs.callPackage ./mole {};
  zapier-platform-cli = pkgs.callPackage ./zapier-platform-cli {};
  spiral-cli = pkgs.callPackage ./spiral-cli {};
  readwise-cli = pkgs.callPackage ./readwise-cli {};
  hermes-agent = pkgs.callPackage ./hermes-agent {};
  vault-gardener = pkgs.callPackage ./vault-gardener {};
  obsidian-headless = pkgs.callPackage ./obsidian-headless {};

  # simonw tools
  claude-code-transcripts = pkgs.callPackage ./claude-code-transcripts {};
  exa-py = pkgs.callPackage ./exa-py {};
  ttok = pkgs.callPackage ./ttok {};
  rodney = pkgs.callPackage ./rodney {};
  showboat = pkgs.callPackage ./showboat {};

} // lib.optionalAttrs pkgs.stdenv.isDarwin {
  vimr = pkgs.callPackage ./vimr {};
  icalpal = pkgs.callPackage ./icalpal {};

} // lib.optionalAttrs (pkgs.stdenv.isDarwin && pkgs.stdenv.isAarch64) {
  mlx-lm = pkgs.callPackage ./mlx-lm {};
}
