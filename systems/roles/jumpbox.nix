{ pkgs, ... }: {
  # Jumpbox profile - secure entry point with administrative capabilities
  # Use case: Remote servers, headless machines, secure access points
  # Needs security, user management, and admin tools
  
  imports = [
    ../modules/base
    ../modules/nix-core
    ../modules/shells
    ../modules/essential-packages
    ../modules/networking-tools
    ../modules/user-management
    ../modules/security
    ../modules/services
    ../modules/development
    ../modules/system-defaults
    ../modules/home-lab
  ];
}
