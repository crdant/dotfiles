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
  home = {
    packages = with pkgs; [
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
  
    file = {
      # can't quite configure gnupg the way I want within programs.gnupg
      ".gnupg" = {
        source = ./config/gnupg;
        recursive = true;
      };

      ".step" = {
        source = ./config/step;
        recursive = true;
      };

    } // lib.optionalAttrs isDarwin {
      ".gnupg/gpg-agent.conf" = {
        source = ./config/gpg-agent/gpg-agent.conf;
        recursive = true;
      };
    } ;
  };

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
  
  
  programs = {
    zsh = {
      oh-my-zsh.plugins = [
      ] ++ lib.optionals isDarwin [
        "gpg-agent"
      ];
      
      envExtra = ''
        export CERTBOT_ROOT="${config.xdg.dataHome}/certbot"
      '';
    };
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
