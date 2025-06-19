{ inputs, outputs, config, pkgs, lib, gitEmail, secretsFile ? null, ... }:

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
        age
        cosign
        sops
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
  
  sops = lib.mkIf (secretsFile != null) {
    defaultSopsFile = secretsFile;
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
      
    };
  };
  
}
