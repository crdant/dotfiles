{ pkgs, inputs, ... }:
{

  imports = [
    ./common.nix
  ];

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
      };
      efi = {
        canTouchEfiVariables = true;
      };
    };
  };

  networking = {
    firewall = {
      enable = true;
    };
    # turn off IPv6 for now while sorting out a plan for it
    enableIPv6 = false;
  };

  security = {
    pki = {
      installCACerts = true ;
      certificateFiles = [
        ../pki/shortrib-labs-e1.crt
        ../pki/shortrib-labs-r2.crt
      ];
    };
    sudo = {
      enable = true;
      execWheelOnly = true;
      wheelNeedsPassword = false ;
    };
  };

  services = {
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

  system = {
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

  users = { 
    users.crdant = {
      uid = 1001;
    };
  };

  virtualisation = {
    vmware = {
      guest.enable = true ;
    };
  };
}
