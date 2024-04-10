{ inputs, outputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../linux.nix 
  ];

  networking = {
    hostName = "mash";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };
} 
