{ inputs, pkgs, ... }:
let
  authorizedKeysFile = builtins.fetchurl {
    url = "https://github.com/crdant.keys";
  };

  authorizedKeys = let
      content = builtins.readFile authorizedKeysFile;
    in
      builtins.filter (entry: entry != [] && entry != "") (builtins.split "\n" content);
in
{
  # The user should already exist, but we need to set this up so Nix knows
  # what our home directory is (https://github.com/LnL7/nix-darwin/issues/423).

  users.users.chuck = {
    home = "/Users/chuck";
    shell = pkgs.zsh;

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
