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
    openssh = {
      enable = true;
      permitRootLogin = "no";
      passwordAuthentication = false;
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
      description = "Chuck D'Antonio";
      home = "/home/crdant"
    };
  };

  virtualisation = {
    vmware = {
      guest.enable = true ;
    };
  };
}
