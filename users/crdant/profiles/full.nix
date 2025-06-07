{ pkgs, ... }: {
  # Full workstation profile with all modules
  imports = [
    ../modules/base.nix
    ../modules/development.nix
    ../modules/ai.nix
    ../modules/kubernetes.nix
    ../modules/replicated.nix
    ../modules/security.nix
    ../modules/cloud.nix
    ../modules/home-network.nix
    ../modules/homelab.nix
  ];
}
