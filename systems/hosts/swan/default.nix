{ inputs, outputs, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../roles/dns.nix 
  ];

  system.stateVersion = "24.11";

  networking = {
    hostName = "swan";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };
} 
