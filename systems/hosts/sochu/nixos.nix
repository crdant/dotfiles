{ inputs, outputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
  ];

  hardware.asahi.enable = true;
}
