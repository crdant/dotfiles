{ pkgs, ... }: {
  # Full workstation profile with all modules
  imports = [
    ../modules/base
    ../modules/development
    ../modules/ai
    ../modules/kubernetes
    ../modules/replicated
    ../modules/security
    ../modules/cloud
    ../modules/home-network
    ../modules/homelab
  ];
}
