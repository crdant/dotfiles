{ inputs, outputs, config, pkgs, lib, username, homeDirectory, gitEmail, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin ;
  isLinux = pkgs.stdenv.isLinux ;
in {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.

  imports = [
    inputs._1password-shell-plugins.hmModules.default
  ];

  nixpkgs = {
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
  };

  home = {
    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    username = "${username}";
    homeDirectory = "${homeDirectory}";
    
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "23.11";

    # specify variables to use in all logins across shells
    sessionVariables = {
      EDITOR = "nvim" ;
      VISUAL = "nvim" ;
      NIXPKGS_ALLOW_UNFREE = 1;
      NIXPKGS_ALLOW_BROKEN = 1;
    };

    sessionPath = [
      "$HOME/.local/bin" 
      "$HOME/.krew/bin"
      "$HOME/workspace/go/bin"
    ] ++ lib.optionals isDarwin [
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
    ] ++ [
      "/usr/local/bin"
      "/usr/local/sbin"
    ]; 

    # Specify packages not explicitly configured below
    packages = with pkgs; [
      argocd
      azure-cli
      certbot-full
      cloudflared
      conftest
      cosign
      crane
      cue
      exercism
      gh
      google-cloud-sdk
      govc
      krew
      kubectl
      kubernetes-helm
      istioctl
      k0sctl
      kubeseal
      kustomize
      minio-client
      oras
      packer
      rar
      replicated
      ripgrep
      shellcheck
      sipcalc
      skopeo
      sops
      step-cli
      stern
      syft
      tcptraceroute
      tcptraceroute
      tektoncd-cli
      terraform
      vault
      vendir
      ytt
      # yubico-pam
      yubico-piv-tool
      yubikey-manager
      zsh-completions
    ] ++ lib.optionals isDarwin [
      # gui apps
      # discord
      # minikube
      unstable.postman
      vimr
      # vscode
    ] ++ lib.optionals isLinux [
      unstable._1password
      unstable._1password-gui-beta
      calicoctl
      coreutils
      dogdns
      gist
      gnupg
      hostess
      jq
      knot-dns
      nerdctl
      nmap
      opensc
      powershell
      procps
      pstree
      sipcalc
      tailscale
      tcptraceroute
      yq-go
      zsh-completions
    ] ;

    file = {
      # can't quite configure gnupg the way I want within programs.gnupg
      ".curlrc" = {
        text = "-fL";
      };

      ".editorconfig" = {
        source = ./config/editorconfig;
      };

      "Library/Application Support/espanso" = {
        source = ./config/espanso;
        recursive = true;
      };

      "Library/Preferences/glow" = {
        source = ./config/glow;
        recursive = true;
      };

      ".gnupg" = {
        source = ./config/gnupg;
        recursive = true;
      };

      ".hammerspoon" = {
        source = ./config/hammerspoon;
        recursive = true;
      };

      ".config/nvim" = {
        source = ./config/nvim;
        recursive = true ;
      };
      ".config/ssh/config.d" = {
        source = ./config/ssh/config.d;
        recursive = true;
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs = {
    _1password-shell-plugins = {
      enable = true;
      plugins = with pkgs; [
        awscli2
        gh
      ];
    };

    atuin = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      flags = [
        "--disable-up-arrow"
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

    direnv = {
      enable = true ;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      nix-direnv.enable = true;
    }; 

    fzf = {
      enable = true;
      enableZshIntegration = false;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };

    gh = {
      enable = true;
      settings = {

        aliases = {
          co = "pr checkout";
          pv = "pr view";
        };
        git_protocol = "ssh";
      };
    };

    git = {
      enable = true ;

      userName = "Chuck D'Antonio";
      userEmail = "${gitEmail}";

      signing = {
        key = "0805EEDF0FEA6ACD";
        signByDefault = true ;
      };

      aliases = { 
        ignore = "update-index --skip-worktree";
        unignore = "update-index --no-skip-worktree";
        ignored = "!git ls-files -v | grep \"^S\"";
        praise = "blame";
      };

      extraConfig = {
        core = {
          editor = "nvim";
          whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
          
          # If git uses `ssh` from Nix the macOS-specific configuration in
          # `~/.ssh/config` won't be seen as valid
          # https://github.com/NixOS/nixpkgs/issues/15686#issuecomment-865928923
          sshCommand = "${pkgs.openssh}/bin/ssh";
        };

        color = {
          ui = true;

          branch = { 
            current = "yellow reverse";
            local = "yellow";
            remote = "green";
          };

          diff = {
            meta = "yellow bold";
            frag = "magenta bold";
            old = "red bold";
            new = "green bold";
            whitepace = "red reverse";
          };

          status = {
            added = "yellow";
            change = "green";
            untracked = "cyan";
          };

          merge = {
            conflictstyle = "zdiff3";
          };

          branch = {
            sort = "-commiterdate";
          };

        };

        init = {
          defaultBranch = "main";
        };

        diff = {
          plist = {
            textconv = "plutil -p";
          };
        };
      } // lib.optionals isDarwin {
        credential = {
          helper = "osxkeychain";
        };
      };
    };

    go = {
      enable = true;
      goPath = "workspace/go";
    };

    home-manager.enable = true;

    neovim = {
      enable = true ;
      viAlias = true;
      vimAlias = true;

      plugins = with pkgs.vimPlugins; [
        editorconfig-nvim
        {
          plugin = NeoSolarized;
          config = "colorscheme NeoSolarized";
        }
        nvim-fzf
        nvim-surround
        vim-commentary
        vim-repeat
        zoxide-vim
      ];

      extraLuaConfig = ''
        -- General
        vim.opt.encoding = "utf-8"          -- The encoding displayed
        vim.opt.fileencoding = "utf-8"      -- The encoding written to file
        vim.cmd("syntax on")                -- Enable syntax highlight
        vim.opt.ttyfast = true              -- Faster redrawing
        vim.opt.lazyredraw = true           -- Only redraw when necessary
        vim.opt.cursorline = true           -- Find the current line quickly.

        -- go to normal mode when the window loses focus
        vim.cmd[[
          "autocmd FocusLost * call feedkeys("\<esc>")
        ]]

        -- Indentation

        -- Use spaces instead of tabs
        vim.opt.expandtab = true

        -- Be smart when using tabs ;)
        -- :help smarttab
        vim.opt.smarttab = true

        -- 1 tab == 4 spaces
        vim.opt.shiftwidth = 2
        vim.opt.tabstop = 2
        vim.opt.softtabstop = 2

        -- Auto indent
        -- Copy the indentation from the previous line when starting a new line
        vim.opt.ai = true

        -- Smart indent
        -- Automatically inserts one extra level of indentation in some cases, and works for C-like files
        vim.opt.si = true

        -- Keymappings

        -- dont use arrowkeys
        vim.api.nvim_set_keymap(
          "n",
          "<UP>",
          "<NOP>",
          { noremap = true }
        )
        vim.api.nvim_set_keymap(
          "n",
          "<DOWN>",
          "<NOP>",
          { noremap = true }
        )
        vim.api.nvim_set_keymap(
          "n",
          "<LEFT>",
          "<NOP>",
          { noremap = true }
        )
        vim.api.nvim_set_keymap(
          "n",
          "<RIGHT>",
          "<NOP>",
          { noremap = true }
        )

        -- really, just dont
        vim.api.nvim_set_keymap(
          "i",
          "<UP>",
          "<NOP>",
          { noremap = true }
        )
        vim.api.nvim_set_keymap(
          "i",
          "<DOWN>",
          "<NOP>",
          { noremap = true }
        )
        vim.api.nvim_set_keymap(
          "i",
          "<LEFT>",
          "<NOP>",
          { noremap = true }
        )
        vim.api.nvim_set_keymap(
          "i",
          "<RIGHT>",
          "<NOP>",
          { noremap = true }
        )

        vim.api.nvim_set_keymap(
          "n",
          "<C-P>",
          ":Files<CR>",
          { noremap = true }
        )

        -- Appearance
        if vim.fn.has('g:gui_vimr') == 1 then
          vim.opt.background = "light"
        end

        -- line numbers
        -- set relativenumber
        vim.opt.number = true
      '';
    };

    tmux = {
      enable = true ;
      keyMode = "vi" ;
      sensibleOnTop = true ;

      plugins = [
        pkgs.tmuxPlugins.yank
      ];

      extraConfig = ''
        # switch panes using Alt-arrow without prefix
        bind-key -n M-Left select-pane -L
        bind-key -n M-Right select-pane -R
        bind-key -n M-Up select-pane -U
        bind-key -n M-Down select-pane -D

        # Shift arrow to switch windows
        bind -n S-Left  previous-window
        bind -n S-Right next-window
      '';
    };

    ssh = {
      enable = true ;
      hashKnownHosts = true ;

      includes = [
        "~/.config/ssh/config.d/*"
      ];

      matchBlocks = {
        "10.13.6.204 bridge.things.crdant.net homebridge.things.crdant.net" = {
          user = "pi";
        };
        "exit.crdant.net" = {
          hostname = "exit.crdant.net";
          user = "arceus";
          identityFile = "~/.ssh/id_router.pub";
          extraOptions = {
            identityAgent = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
          };
        };
        "router" = {
          hostname = "router";
          user = "arceus";
          identityFile = "~/.ssh/id_router.pub";
          extraOptions = {
            identityAgent = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
            canonicalizeHostName = "yes" ;
            canonicalDomains = "lab.shortrib.net crdant.io.beta.tailscale.net";
          };
        };
        "unifi.crdant.net" = {
          hostname = "unifi.crdant.net";
          user = "root";
          identityFile = "~/.ssh/id_unifi.pub";
          extraOptions = {
            hostKeyAlgorithms = "+ssh-rsa";
            identityAgent = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
          };
        };
        "rye.lab.shortrib.net bourbon.lab.shortrib.net scotch.lab.shortrib.net potstill.lab.shortrib.net shine.lab.shortrib.net malt.lab.shortrib.net vcenter.lab.shortrib.net" = {
          user = "root";
          identityFile = "~/.ssh/id_homelab.pub";
          extraOptions = {
            identityAgent = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
          };
        };
        "gitlab.com" = {
          hostname = "gitlab.com";
          identityFile = "~/.ssh/id_rsa_gitlab.com.pub";
          extraOptions = {
            identityAgent = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
          };
        };
        "ssh.dev.azure.com" = {
          hostname = "ssh.dev.azure.com";
          identityFile = "~/.ssh/id_azure-devops.pub";
          extraOptions = {
            identityAgent = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
          };
        };
      };
      extraConfig = ''
        User crdant
        IgnoreUnknown UseKeychain
        UseKeychain yes
        PasswordAuthentication no
      '' ;
    };

    yt-dlp = { 
      enable = true ;
    };

    zsh = {
      enable = true ;
      enableCompletion = true ;

      oh-my-zsh = {
        enable = true ;
        custom = "$HOME/workspace/oh-my-zsh-custom" ;
        theme = "crdant" ;

        plugins = [ 
          "git"
          "gh"
          "gpg-agent"
          "tmux"
          "emoji"
          "gcloud"
          "aws"
          "kubectl"
          "kubectx"
          "helm"
          "history-substring-search"
          "vault"
          "terraform"
          "ripgrep"
          "zoxide"
          ] ++ pkgs.lib.optionals isDarwin [
            "iterm2"
            "brew"
            "macos"
            "pasteboard"
        ];
      };

      localVariables = {
        COMPLETION_WAITING_DOTS = true;
      };

      shellAliases = {
        more = "less -X" ;
        pd = "pushd" ;
        pop = "popd" ;
        sha1 = "/usr/bin/openssl sha1" ;
        rmd160 = "/usr/bin/openssl rmd160" ;
        lsock = "sudo /usr/sbin/lsof -i -P" ;
      };

      initExtra = ''
        setopt vi
        setopt nobeep
        setopt inc_append_history
        setopt auto_cd
        setopt bash_auto_list
        setopt no_hup
        setopt correct
        setopt no_always_last_prompt
        setopt complete_aliases
        unsetopt hist_verify

        # completions for minio client
        complete -o nospace -C $(brew --prefix)/bin/mc mc

        # Tmux convenience functions
        function tmux-has-session() { 
          session=$1
          tmux has-session -t $session 2>/dev/null 
        }

        function tmux-session() {
          session=$1
          if tmux-has-session $session; then
            tmux attach -t $session
          else
            tmux new-session -s $session \; source-file "$HOME/.tmux/sessions/$session"
          fi
        }

        function fullscreen() {
          tmux-session fullscreen
        } 

        function window() {
          tmux-session window
        } 

        source /Users/chuck/.config/op/plugins.sh
      '';

      initExtraBeforeCompInit = ''
        fpath+=($HOME/workspce/oh-my-zsh-custom/completions)
      '';

      envExtra = ''
        export XDG_CONFIG_HOME="${config.xdg.configHome}"
        export CERTBOT_ROOT="${config.xdg.dataHome}/certbot"

        export GOVC_URL=https://vcenter.lab.shortrib.net
        export GOVC_USERNAME=administrator@shortrib.local
        # export GOVC_PASSWORD=$(security find-generic-password -a administrator@shortrib.local -s vcenter.lab.shortrib.net -w)
        export GOVC_INSECURE=true

        # GPG Agent as SSH agent
        export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

        # if rancher desktop is installed use it's binaries ONLY for anything not already
        # installed system-wide
        if [[ -d $HOME/.rd ]] ; then
          export PATH=$PATH:"$HOME/.rd/bin"
        fi

        export REPL_USE_SUDO=y
        unset RPS1
      '';

    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };

  };

  launchd = {
    enable = true ;
    agents = {
      "io.crdant.certbotRenewal" = {
        enable = true ;
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
              Weekday = 3 ;
              Hour = 15 ;
              Minute = 48 ;
            }
          ];
          RunAtLoad = true;
          StandardOutPath = "${config.xdg.stateHome}/certbot/renewal.out";
          StandardErrorPath = "${config.xdg.stateHome}/certbot/renewal.err";
        };
      };
    };
  };

  xdg = {
    enable = true;
    configFile = {
      "gcloud/configurations/config_default".text = builtins.readFile ./config/gcloud/config_default ;
    } // lib.optionals isDarwin { 
      "karabiner/karabiner.json".text = builtins.readFile ./config/karabiner/karabiner.json ;
    };
  };
}
