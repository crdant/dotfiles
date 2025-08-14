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
    interfaces = {
      eth0 = {
        ipv4 = {
          addresses = [
            {
              address = "10.105.0.253";
              prefixLength = 24;
            }
          ];
        };
      };
    };

    defaultGateway = "10.105.0.1";
    nameservers = [
      "10.105.0.1"
      # "10.105.0.253"
      # "10.105.0.254"
    ];
  };
} 
