{ pkgs, ... }: {
  # Jumpbox profile - minimal system for SSH access and basic operations
  imports = [
    ../modules/base
    ../modules/linux
  ];
}