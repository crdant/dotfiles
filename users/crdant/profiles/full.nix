{ pkgs, ... }: {
  # Full workstation profile with all modules
  imports = [
    ../modules/base.nix
    ../modules/development.nix
    ../modules/ai.nix
    ../modules/kubernetes.nix
    ../modules/security.nix
    ../modules/cloud.nix
    ../modules/homelab.nix
  ] ++ pkgs.lib.optional pkgs.stdenv.isDarwin ../modules/darwin.nix;
}