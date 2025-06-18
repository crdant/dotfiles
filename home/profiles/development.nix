{ pkgs, lib, ... }: {
  # Development profile with coding tools and environments
  imports = [
    ../modules/base.nix
    ../modules/development.nix
    ../modules/cloud.nix
    ../modules/kubernetes.nix
    ../modules/ai.nix
    ../modules/security.nix
  ] ;
}
