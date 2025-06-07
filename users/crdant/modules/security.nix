{ inputs, outputs, config, pkgs, lib, gitEmail, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  imports = [
    inputs._1password-shell-plugins.hmModules.default
    inputs.sops-nix.homeManagerModules.sops
  ];
  
  # Security-related packages
  home.packages = with pkgs; [
    certbot-full
    cosign
    sops
    step-cli
    syft
    # yubico-pam
    yubico-piv-tool
    yubikey-manager
  ] ++ lib.optionals isLinux [
    gnupg
    opensc
  ];
  
  programs = {
    _1password-shell-plugins = {
      enable = true;
      plugins = with pkgs; [
      ] ++ lib.optionals isDarwin [
        awscli2
        gh
        ngrok
      ];
    };
    
    ssh = {
      enable = true;
      hashKnownHosts = true;
      
      includes = [
        "${config.xdg.configHome}/ssh/config.d/*"
      ];
      
      # Common configs for all hosts
      extraConfig = ''
        User crdant
        IgnoreUnknown UseKeychain
        UseKeychain yes
        PasswordAuthentication no
      '';
    };
  };
  
  sops = {
    defaultSopsFile = ../secrets.yaml;  # Path to your secrets file
    gnupg = {
      home = "${config.home.homeDirectory}/.gnupg";
    };
  };
  
  home.file = {
    ".gnupg" = {
      source = ../config/gnupg;
      recursive = true;
    };
    
    ".step" = {
      source = ../config/step;
      recursive = true;
    };
  } // lib.optionalAttrs isDarwin {
    ".gnupg/gpg-agent.conf" = {
      source = ../config/gpg-agent/gpg-agent.conf;
      recursive = true;
    };
  };
  
  xdg.configFile = {
    "ssh/config.d" = {
      source = ../config/ssh/config.d;
      recursive = true;
    };
    
    "git/allowed-signers" = {
      text = ''
        # allow FIDO SSH key on my personal Yubikey to sign commits
        chuck@crdant.io namespaces="git" sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIH76RbmzI1NX9SGvDUUnX0QAVmF5pzr6mHZNG2rd0jAoAAAABHNzaDo= crdant@grappa
        chuck@replicated.com namespaces="git" sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIH76RbmzI1NX9SGvDUUnX0QAVmF5pzr6mHZNG2rd0jAoAAAABHNzaDo= crdant@grappa
        chuck@rcrdant.io namespace="git" ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBKZNf1+SIohm48DXEa1Xssz1ZV8oPxI3Uij1IyZrU3UmQeGkZeu+Vin88qX5UizFat8wd1P88CQk2yaRAIgPKOc=
        chuck@replicated.com namespace="git" ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBKZNf1+SIohm48DXEa1Xssz1ZV8oPxI3Uij1IyZrU3UmQeGkZeu+Vin88qX5UizFat8wd1P88CQk2yaRAIgPKOc=
      '';
    };
  };
  
  programs.zsh = {
    oh-my-zsh.plugins = [
      "gpg-agent"
    ] ++ lib.optionals isDarwin [
      "gpg-agent"
    ];
    
    envExtra = ''
      export CERTBOT_ROOT="${config.xdg.dataHome}/certbot"
    '';
  };
  
  launchd = if isDarwin then {
    enable = true;
    agents = {
      "io.crdant.certbotRenewal" = {
        enable = true;
        config = {
          Label = "io.crdant.certbotRenewal";
          ProgramArguments = [
            "${pkgs.certbot}"
            "renew"
            "--config-dir"
            "${config.xdg.dataHome}/certbot"
            "--work-dir"
            "${config.xdg.stateHome}/certbot/var"
            "--logs-dir"
            "${config.xdg.stateHome}/certbot/logs"
          ];
          StartCalendarInterval = [
            {
              Weekday = 3;
              Hour = 15;
              Minute = 48;
            }
          ];
          RunAtLoad = true;
          StandardOutPath = "${config.xdg.stateHome}/certbot/renewal.out";
          StandardErrorPath = "${config.xdg.stateHome}/certbot/renewal.err";
        };
      };
    };
  } else {
    enable = false;
  };
}
