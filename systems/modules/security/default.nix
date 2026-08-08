{ pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Security configuration for both Darwin and Linux
  environment = {
    systemPackages = with pkgs; [
      unstable._1password-cli
      nmap
    ];
  };
  
  # GPG against the YubiKey's OpenPGP applet needs a smartcard daemon and
  # udev rules granting the console user access; macOS ships both built in
  services = lib.optionalAttrs isLinux {
    pcscd.enable = true;
    udev.packages = [ pkgs.yubikey-personalization ];
  };

  security = {
    pki = {
      installCACerts = true ;
      certificateFiles = [
        ../../../pki/shortrib-labs-e1.crt
        ../../../pki/shortrib-labs-r2.crt
      ];
    };
  } // lib.optionalAttrs isDarwin {
    pam.services.sudo_local.touchIdAuth = true;
  } // lib.optionalAttrs isLinux {
    sudo = {
      enable = true;
      execWheelOnly = true;
      wheelNeedsPassword = false ;
    };
  };
}
