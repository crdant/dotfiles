{ inputs, outputs, options, config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  home.packages = with pkgs; [
    unstable.atproto-goat
  ];

  sops.secrets."atproto/pds/adminPassword" = {};

  home.sessionVariables = {
    PDS_HOST = "pds.shortrib.io";
  };

  programs.zsh.envExtra = ''
    export PDS_ADMIN_PASSWORD="$(cat ${config.sops.secrets."atproto/pds/adminPassword".path})"
  '';

  programs.fish.shellInit = ''
    set -gx PDS_ADMIN_PASSWORD (cat ${config.sops.secrets."atproto/pds/adminPassword".path})
  '';
}
