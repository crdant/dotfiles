{ pkgs, lib, inputs, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # System services configuration
  
  boot = lib.mkIf isLinux {
    loader = {
      systemd-boot = {
        enable = true;
      };
      efi = {
        canTouchEfiVariables = true;
      };
    };
  };

  networking = lib.mkIf isLinux {
    firewall = {
      enable = true;
    };
    # turn off IPv6 for now while sorting out a plan for it
    enableIPv6 = false;
  };

  services = lib.mkIf isLinux {
    resolved = {
      enable = true;
      domains = [
        "lab.shortrib.net"
        "crdant.net"
      ];
      fallbackDns = [ "10.25.0.1" ];
    };
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
      extraConfig = '' 
        StreamLocalBindUnlink yes 
      ''; 
    };
  };

  system = lib.mkIf isLinux {
    autoUpgrade = {
      enable = true;
      allowReboot = true;
      flake = inputs.self.outPath;
      flags = [
        "--update-input"
        "nixpkgs"
        "--no-write-lock-file"
        "-L" # print build logs
      ];
      dates = "02:00";
      randomizedDelaySec = "45min";
    };
  };

  users = lib.mkIf isLinux { 
    users.crdant = {
      uid = 1001;
    };
  };

  virtualisation = lib.mkIf isLinux {
    vmware = {
      guest.enable = true ;
    };
  };
}