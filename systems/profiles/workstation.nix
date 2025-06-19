{ ... }: {
  # Workstation profile - full-featured system for development and daily use
  # Use case: Developer workstations, personal computers, admin machines
  # Size: ~120 lines of configuration (equivalent to current base module)
  
  imports = [
    ../modules/nix-core
    ../modules/shells
    ../modules/essential-packages
    ../modules/networking-tools
    ../modules/user-management
  ];
}
EOF < /dev/null