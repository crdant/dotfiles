{ pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Security configuration for both Darwin and Linux
  environment = {
    systemPackages = with pkgs; [
      nmap
    ];
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
