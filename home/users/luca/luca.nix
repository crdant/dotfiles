{ inputs, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in
{
  users.users.luca = {
    home = if isDarwin then
      "/Users/luca"
    else
      "/home/luca";

    shell = pkgs.zsh;
    description = "Luca Aragosta";
  } // lib.optionalAttrs isLinux {
    isNormalUser = true;
    group = "luca";
    extraGroups = [ "adm" "sudo" "wheel" ];
  };
}
