{ inputs, outputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../roles/jumpbox.nix
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
    enableIPv6 = true;
    # Use systemd-networkd for proper integration with systemd-resolved
    useNetworkd = true;
    useDHCP = false;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  # Configure ens3 via systemd-networkd to get DHCP DNS into resolved
  systemd.network = {
    enable = true;
    networks."10-ens3" = {
      matchConfig.Name = "ens3";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
        DNSDefaultRoute = true;
      };
      dhcpV4Config = {
        UseDNS = true;
      };
      ipv6AcceptRAConfig = {
        UseDNS = true;
      };
    };
  };

  # Enable Tailscale with DNS integration
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  # Enable systemd-resolved for split DNS
  # Tailscale will configure its interface to route ~walrus-shark.ts.net to 100.100.100.100
  # DHCP DNS servers handle all other queries
  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    # "true" = strict (fail if DoT unavailable), "opportunistic" = use DoT when available
    dnsovertls = "opportunistic";
  };

  # Skip DNSSEC validation for internal domains where authoritative DNS
  # is signed externally but internal records are unsigned
  # See: https://man.archlinux.org/man/core/systemd/dnssec-trust-anchors.d.5.en
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
} 
