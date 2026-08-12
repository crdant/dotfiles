{ pkgs, lib, options, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in lib.mkMerge [ {
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

    # pcsclite builds against polkit when polkit is enabled (NetworkManager
    # enables it), which gates smartcard access per client; let admins reach
    # the YubiKey from any session, not just an active local seat
    polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if ((action.id == "org.debian.pcsc-lite.access_pcsc" ||
             action.id == "org.debian.pcsc-lite.access_card") &&
            subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
(lib.optionalAttrs (builtins.hasAttr "powerManagement" options) {
  # scdaemon keeps a stale handle to the reader across suspend, leaving the
  # card invisible after wake until it's physically reseated; freshen the
  # smartcard stack on resume so gpg's next touch re-enumerates it. The key
  # itself is conditional inside mkMerge — nix-darwin rejects the namespace
  # even as an empty attrset, and a plain // merge on the module body
  # recurses.
  powerManagement.resumeCommands = ''
    ${pkgs.systemd}/bin/systemctl try-restart pcscd.service
    ${pkgs.procps}/bin/pkill -x scdaemon || true
  '';
}) ]
