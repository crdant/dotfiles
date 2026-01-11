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

  # Skip DNSSEC validation for internal domains where authoritative DNS
  # is signed externally but internal records are unsigned
  # See: https://man.archlinux.org/man/core/systemd/dnssec-trust-anchors.d.5.en
  dnssecConfig = {
    environment.etc."dnssec-trust-anchors.d/internal.negative".text = ''
      ; Domains with external DNSSEC signing but unsigned internal records
      lab.shortrib.net
      shortrib.net
      shortrib.dev
      shortrib.app
      shortrib.run
      shortrib.io
      shortrib.sh
      shortrib.life
    '';
  };

  supportsTailscale = builtins.hasAttr "tailscale" options.services;
  tailscaleConfig = lib.optionalAttrs supportsTailscale {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };
  };
in lib.mkMerge [
  vmwareConfig
  networkdConfig
  dnssecConfig
  tailscaleConfig
]
