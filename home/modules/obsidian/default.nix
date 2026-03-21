{ pkgs, lib, ... }:

let
  isLinux = pkgs.stdenv.isLinux;
in {
  home.packages = with pkgs; [
    obsidian-headless
  ] ++ lib.optionals isLinux [
    unstable.obsidian
  ];
}
