{ inputs, outputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/jumpbox.nix 
  ];

  system.stateVersion = "24.11";

  boot.binfmt.emulatedSystems = [ 
    "aarch64-linux"
    "riscv64-linux"
    "wasm32-wasi"
    "mipsel-linux"
  ];

  networking = {
    hostName = "mash";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };
} 
