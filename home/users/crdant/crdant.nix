{ inputs, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin ;
  isLinux = pkgs.stdenv.isLinux ;

  authorizedKeys = import ./authorized-keys.nix;
in
{
  # The user should already exist, but we need to set this up so Nix knows
  # what our home directory is (https://github.com/LnL7/nix-darwin/issues/423).
  users = {
    users.crdant = {
      home = if isDarwin then
        "/Users/crdant"
      else
        "/home/crdant";

      shell = pkgs.fish;
      description = "Chuck D'Antonio";

      openssh.authorizedKeys.keys = authorizedKeys;

    } // lib.optionalAttrs isDarwin {
      uid = 501;
    } // lib.optionalAttrs isLinux {
      isNormalUser = true;
      group = "crdant";
      extraGroups = [ "adm" "ssher" "sudo" "wheel" ];
    };
  } // lib.optionalAttrs isDarwin {
    knownUsers = [ "crdant" ];
  } // lib.optionalAttrs isLinux {
    groups.crdant = {
      gid = 1002;
    };
  };


  system = {
  } // lib.optionalAttrs isDarwin {
    primaryUser = "crdant";
    defaults = { 
      screencapture.location = "/Users/crdant/Documents/Outbox";
    };
  };
}
