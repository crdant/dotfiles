{ pkgs, lib, options, ... }:

let
  supportsVirtualisation = builtins.hasAttr "virtualisation" options;
  vmwareConfig = lib.optionalAttrs supportsVirtualisation {
    virtualisation = {
      vmware = {
        guest.enable = true ;
      };
    };
  };

  supportsNetworkd = builtins.hasAttr "network" options.systemd;
  networkdConfig = lib.optionalAttrs supportsNetworkd {
    systemd.network.networks."20-home-lab-defaults" = {
      # Match all ethernet interfaces as a fallback
      matchConfig.Type = "ether";
      networkConfig = {
        # Accept IPv6 Router Advertisements for address and DNS configuration
        IPv6AcceptRA = true;
      };
      ipv6AcceptRAConfig = {
        UseDNS = true;
      };
    };
  };
in lib.mkMerge [
  vmwareConfig
  networkdConfig
]
