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
    # Override system-defaults which disables IPv6
    enableIPv6 = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  # Host-specific network interface configuration
  systemd.network.networks."10-ens3" = {
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
} 
