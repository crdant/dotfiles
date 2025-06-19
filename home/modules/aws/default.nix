{ inputs, outputs, config, pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # AWS tools and services
  home.packages = with pkgs; [
    aws-sam-cli
    eksctl
  ];

  programs = {
    _1password-shell-plugins = {
      enable = true;
      plugins = with pkgs; [
        awscli2
      ];
    };
    
    awscli = {
      enable = true;
      settings = {
        "default" = {
          region = "us-west-2";
          output = "json";
        };
        "personal" = {
          region = "us-west-2";
          output = "json";
        };
        "replicated-dev" = {
          region = "us-west-2";
          output = "json";
        };
      };
    };
    zsh = {
      oh-my-zsh = {
        plugins = [
          "aws"
        ];
      };
    };
  };
}