{ pkgs, ... }: {
  # Workstation profile - full desktop environment with development tools
  imports = [
    ../modules/base
    ../modules/security
    ../modules/desktop
    ../modules/system-defaults
  ];
}