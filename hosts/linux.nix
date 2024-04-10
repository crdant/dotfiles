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
  }

  virtualisation = {
    vmware = {
      guest.enable = true ;
    }
  };
}
