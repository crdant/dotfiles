{ pkgs, ... }: {
  # AI-focused profile for working with AI tools and assistants
  imports = [
    ../modules/base.nix
    ../modules/development.nix
    ../modules/ai.nix
    ../modules/security.nix
  ] ++ pkgs.lib.optional pkgs.stdenv.isDarwin ../modules/darwin.nix;
}