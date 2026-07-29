{ inputs, pkgs, lib, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin ;
  isLinux = pkgs.stdenv.isLinux ;

  authorizedKeys = import ./authorized-keys.nix;
in
{
  # The user should already exist, but we need to set this up so Nix knows
  # what our home directory is (https://github.com/LnL7/nix-darwin/issues/423).

  users.knownUsers = [ "chuck" ];

  users.users.chuck = {
    home = "/Users/chuck";
    shell = pkgs.fish;
    uid = 503;

    description = "Chuck D'Antonio";

    openssh.authorizedKeys.keys = authorizedKeys;
  };

  system = {
    primaryUser = "chuck";
  } // lib.optionalAttrs isDarwin {
    defaults = { 
      screencapture.location = "/Users/chuck/Documents/Outbox";
    };
  };
}
