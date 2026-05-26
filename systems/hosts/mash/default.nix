{ inputs, outputs, pkgs, config, ... }:
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

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      "restic/password" = {};
      "restic/r2-access-key-id" = {};
      "restic/r2-secret-access-key" = {};
    };
    templates."restic-environment" = {
      content = ''
        AWS_ACCESS_KEY_ID=${config.sops.placeholder."restic/r2-access-key-id"}
        AWS_SECRET_ACCESS_KEY=${config.sops.placeholder."restic/r2-secret-access-key"}
      '';
    };
  };

  services.restic.backups.mash = {
    repository = "s3:https://e1c1e3525fe50237ffabe45f58cd5f6d.r2.cloudflarestorage.com/backup/mash";
    passwordFile = config.sops.secrets."restic/password".path;
    environmentFile = config.sops.templates."restic-environment".path;
    paths = [ "/home/crdant" "/var/lib" ];
    pruneOpts = [ "--keep-daily 3" "--keep-weekly 3" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };
}
