{ pkgs, ... }: {
  # Jumpbox profile - minimal system for SSH access and basic operations
  # Use case: Remote servers, headless machines, secure access points
  # Based on container profile + minimal security
  
  imports = [
    ../modules/nix-core
    ../modules/shells
    ../modules/networking-tools
    ../modules/services
  ];
}