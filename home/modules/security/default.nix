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
        tunnelmanager
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
    # _1password-shell-plugins = {
    #   enable = true;
    #   plugins = with pkgs; [
    #   ];
    # };
    
    neovim = {
      # Core plugins used everywhere
      plugins = with pkgs.vimPlugins; [
        nvim-sops 
      ];

      extraLuaConfig = ''
        vim.keymap.set('n', '<leader>ef', vim.cmd.SopsEncrypt, { desc = '[E]ncrypt [F]ile' })
        vim.keymap.set('n', '<leader>df', vim.cmd.SopsDecrypt, { desc = '[D]ecrypt [F]ile' })
      '';
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          user = "crdant";
          forwardAgent = false;
          addKeysToAgent = "yes";
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          hashKnownHosts = true;
          userKnownHostsFile = "~/.ssh/known_hosts";
          controlMaster = "yes";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "no";
          extraOptions = {
            passwordAuthentication = "no";
          };
        };
      };

      includes = [
        "${config.xdg.configHome}/ssh/config.d/*"
      ];
      
      # Common configs for all hosts
      extraConfig = ''
        IgnoreUnknown UseKeychain
        UseKeychain yes
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
