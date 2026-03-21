{ inputs, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in
{
  users.users.dewey = {
    home = if isDarwin then
      "/Users/dewey"
    else
      "/home/dewey";

    shell = pkgs.zsh;
    description = "Dewey";
  } // lib.optionalAttrs isLinux {
    isNormalUser = true;
    group = "dewey";
    extraGroups = [ "adm" "sudo" "wheel" ];
  };
}
