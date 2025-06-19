{ inputs, outputs, config, pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Google Cloud tools and services
  home.packages = with pkgs; [
    google-cloud-sdk
  ];

  programs = {
    zsh = {
      oh-my-zsh = {
        plugins = [
          "gcloud"
        ];
      };
    };
  };
}