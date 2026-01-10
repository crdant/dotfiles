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
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
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
} 
