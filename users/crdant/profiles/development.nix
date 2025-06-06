{ pkgs, ... }: {
  # Development profile with coding tools and environments
  imports = [
    ../modules/base.nix
    ../modules/development.nix
    ../modules/ai.nix
    ../modules/security.nix
  ] ++ pkgs.lib.optional pkgs.stdenv.isDarwin ../modules/darwin.nix;
}