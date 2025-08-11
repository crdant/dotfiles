{ inputs, outputs, pkgs, ... }:
{
  imports = [
    ../../roles/dns.nix 
  ];

  system.stateVersion = "24.11";

  networking = {
    hostName = "swan";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22, 53, 853 ];
      allowedUDPPorts = [ 53 ];
    };
  };
} 
