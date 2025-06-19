{ pkgs, ... }: {
  # Jumpbox profile - minimal system for SSH access and basic operations
  # Use case: Remote servers, headless machines, secure access points
  # Based on container profile + security and services
  
  imports = [
    ../modules/nix-core
    ../modules/shells
    ../modules/networking-tools
    ../modules/user-management
    ../modules/security
    ../modules/services
  ];
}