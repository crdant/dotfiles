{ inputs, outputs, config, pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Azure tools and services
  home.packages = with pkgs; [
    azure-cli
  ];

  programs = {
    zsh = {
      oh-my-zsh = {
        plugins = [
        ];
      };
    };
  };
}