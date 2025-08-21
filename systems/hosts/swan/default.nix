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
      ens32 = {
        ipv4 = {
          addresses = [
            {
              address = "10.105.0.251";
              prefixLength = 24;
            }
            {
              address = "10.105.0.252";
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

  services.dnsServerDefaults = {
    identity = "shortrib-dns";
    primaryDnsIP = "10.105.0.251";
    primaryResolverIP = "10.105.0.252";

    secondaryDnsIP = "10.105.0.253";
    secondaryResolverIP = "10.105.0.254";
  };

} 
