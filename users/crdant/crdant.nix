{ inputs, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin ;
  isLinux = pkgs.stdenv.isLinux ;

  authorizedKeysFile = builtins.fetchurl {
    url = "https://github.com/crdant.keys";
    sha256 = "sha256-DMSnRs0hYVa7U2FlBIPZoBLoWlzzoJcRlUZqsFfIvww=";
  };

  authorizedKeys = let
      content = builtins.readFile authorizedKeysFile;
    in
      builtins.filter (entry: entry != [] && entry != "") (builtins.split "\n" content);
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

      shell = pkgs.zsh;
      description = "Chuck D'Antonio";

      openssh.authorizedKeys.keys = authorizedKeys;

    } // lib.optionalAttrs isLinux {
      isNormalUser = true;
      group = "crdant";
      extraGroups = [ "adm" "ssher" "sudo" "wheel" ];
    };
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
