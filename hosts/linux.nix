{ pkgs, ... }:
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
