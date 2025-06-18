{ pkgs, lib, inputs, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  virtualisation = lib.mkIf isLinux {
    vmware = {
      guest.enable = true ;
    };
  };
}
