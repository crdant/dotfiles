{ pkgs, lib, ... }:

let
  isLinux = pkgs.stdenv.isLinux;
in {
  home.packages = lib.optionals isLinux [
    pkgs.unstable.obsidian
  ];
}
