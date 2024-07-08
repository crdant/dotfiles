{ inputs, outputs, config, pkgs, lib, username, homeDirectory, gitEmail, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin ;
  isLinux = pkgs.stdenv.isLinux ;
  vimUtils = pkgs.vimUtils ;
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
      unstable.certbot-full
      cloudflared
      conftest
      cosign
      crane
      cue
      exercism
      gh
      google-cloud-sdk
      govc
      helmfile
      imgpkg
      istioctl
      krew
      kubectl
      kubernetes-helm
      k0sctl
      ko
      kots
      kots2helm
      kubeseal
      kustomize
      kyverno-chainsaw
      mods
      minio-client
      nix-prefetch-git
      nodejs_22
      open-policy-agent
      oras
      packer
      rar
      replicated
      ripgrep
      shellcheck
      sipcalc
      skopeo
      smug
      sops
      step-cli
      stern
      syft
      tcptraceroute
      tektoncd-cli
      terraform
      troubleshoot-sbctl
      tunnelmanager
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
      postman
      vimr
      (callPackage ./vimr-wrapper.nix { inherit config ; })
      # vscode
    ] ++ lib.optionals isLinux [
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
      ".curlrc" = {
        text = "-fL";
      };

      ".editorconfig" = {
        source = ./config/editorconfig;
      };

      # can't quite configure gnupg the way I want within programs.gnupg
      ".gnupg" = {
        source = ./config/gnupg;
        recursive = true;
      };

      ".hammerspoon" = {
        source = ./config/hammerspoon;
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

      "Library/Application Support/espanso" = {
        source = ./config/espanso;
        recursive = true;
      };

      "Library/Colors/Solarized.clr" = {
        source = ./config/palettes/Solarized.clr;
        recursive = true;
      };

      "Library/Colors/Replicated.clr" = {
        source = ./config/palettes/Replicated.clr;
        recursive = true;
      };

      "Library/Preferences/glow" = {
        source = ./config/glow;
        recursive = true;
      };
    } ;
  };

  # Let Home Manager install and manage itself.
  programs = {
    _1password-shell-plugins = {
      enable = true;
      plugins = with pkgs; [
        awscli2
        gh
        ngrok
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

      } // lib.optionalAttrs isDarwin {
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
        conflict-marker-vim
        copilot-vim
        editorconfig-nvim
        {
          plugin = fzf-vim;
          config = ''
            " Initialize configuration dictionary
            let g:fzf_vim = {}
            let g:fzf_vim.preview_window = []
          ''; 
        }
        { plugin = rose-pine;
          config = "colorscheme rose-pine";
        } 
        NeoSolarized
        lsp-zero-nvim
        mason-lspconfig-nvim
        mason-nvim
        vim-surround
        vim-commentary
        vim-repeat
        vim-tmux-navigator
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

        -- 1 tab == 2 spaces
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
        if vim.fn.has('gui_running') == 1 then
          vim.opt.background = "light"
        end

        -- markdown should have spell check and word wrap
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "markdown",
          callback = function()
            vim.opt_local.textwidth = 78
            vim.opt_local.spell = true
          end
        })

        -- Lua-based configuration for Neovim

        -- Ensure Makefiles use tabs
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "make",
          callback = function()
            vim.opt_local.expandtab = false
          end
        })

        -- Set larger indents for Go files
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "go",
          callback = function()
            vim.opt_local.shiftwidth = 8
            vim.opt_local.tabstop = 8
          end
        })

        -- Auto format Go files on save
        vim.api.nvim_create_autocmd("BufWritePre", {
          pattern = "*.go",
          callback = function()
            vim.cmd('silent! !go fmt %')
          end
        })

        -- line numbers
        -- set relativenumber
        vim.opt.number = true

        local lsp_zero = require('lsp-zero')

        lsp_zero.on_attach(function(client, bufnr)
          -- see :help lsp-zero-keybindings
          -- to learn the available actions
          lsp_zero.default_keymaps({buffer = bufnr})
        end)

        require('mason').setup({})
        require('mason-lspconfig').setup({
          -- Replace the language servers listed here 
          -- with the ones you want to install
          ensure_installed = {'tsserver', 'gopls', 'pyright', 'rust_analyzer'},
          handlers = {
            lsp_zero.default_setup,
          },
        })

        -- edits an Instruqt track in a multiple splits
        function ChallengeEdit(args)
          local dir = args.args

          -- open the assignment 
          vim.cmd('tabnew ' .. dir .. '/check-shell')

          -- create a vertical split with the check script, which
          -- will end up at the bottom
          vim.cmd('vnew ' .. dir .. '/assignment.md')

          -- Create two horizontal splits with the remaining files on
          -- right hand side

          vim.cmd('wincmd l')
          vim.cmd('new ' .. dir .. '/solve-shell')
          vim.cmd('new ' .. dir .. '/setup-shell')
        end

        local function challenge_completion(ArgLead, CmdLine, CursorPos)
          return vim.fn.getcompletion(ArgLead, 'dir')
        end

        vim.api.nvim_create_user_command('ChallengeEdit', ChallengeEdit, {
          nargs = 1,
          complete = challenge_completion
        })
      '';
    };

    tmux = {
      enable = true ;
      keyMode = "vi" ;
      sensibleOnTop = true ;

      plugins = [
        pkgs.tmuxPlugins.yank
        pkgs.tmuxPlugins.vim-tmux-navigator 
      ];

      extraConfig = ''
        bind r source-file ~/.tmux.conf

        # switch panes using Alt-arrow without prefix
        bind-key -n M-Left select-pane -L
        bind-key -n M-Right select-pane -R
        bind-key -n M-Up select-pane -U
        bind-key -n M-Down select-pane -D

        # Shift arrow to switch windows
        bind -n S-Left  previous-window
        bind -n S-Right next-window

        # vim-like pane navigation
        bind-key h select-pane -L
        bind-key j select-pane -D
        bind-key k select-pane -U
        bind-key l select-pane -R

        # vim-style copy/paste
        set-window-option -g mode-keys vi
        bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
        bind-key -T copy-mode-vi 'y' send-keys -X copy-selection-and-cancel
        bind-key p paste-buffer
      '';
    };

    ssh = {
      enable = true ;
      hashKnownHosts = true ;

      includes = [
        "${config.xdg.configHome}/ssh/config.d/*"
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
            canonicalizeHostName = "yes" ;
            canonicalDomains = "crdant.net walrus-shark.ts.net crdant.io.beta.tailscale.net";
            identitiesOnly = "yes";
          };
        };
        "router" = {
          hostname = "router";
          user = "arceus";
          identityFile = "~/.ssh/id_router.pub";
          extraOptions = {
            identityAgent = "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
            canonicalizeHostName = "yes" ;
            canonicalDomains = "lab.shortrib.net walrus-shark.ts.net crdant.io.beta.tailscale.net";
            identitiesOnly = "yes";
          };
        };
        "unifi.crdant.net" = {
          hostname = "unifi.crdant.net";
          user = "root";
          identityFile = "~/.ssh/id_unifi.pub";
          extraOptions = {
            hostKeyAlgorithms = "+ssh-rsa";
            identityAgent = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
            identitiesOnly = "yes";
          };
        };
        "rye.lab.shortrib.net bourbon.lab.shortrib.net scotch.lab.shortrib.net potstill.lab.shortrib.net shine.lab.shortrib.net malt.lab.shortrib.net vcenter.lab.shortrib.net" = {
          user = "root";
          identityFile = "~/.ssh/id_homelab.pub";
          extraOptions = {
            identityAgent = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
            identitiesOnly = "yes";
          };
        };
        "gitlab.com" = {
          hostname = "gitlab.com";
          identityFile = "~/.ssh/id_rsa_gitlab.com.pub";
          extraOptions = {
            identityAgent = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
            identitiesOnly = "yes";
          };
        };
        "ssh.dev.azure.com" = {
          hostname = "ssh.dev.azure.com";
          identityFile = "~/.ssh/id_azure-devops.pub";
          extraOptions = {
            identityAgent = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
            identitiesOnly = "yes";
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
            "brew"
            "gpg-agent"
            "iterm2"
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

        # Tmux convenience functions
        function tmux-has-session() { 
          session=$1
          tmux has-session -t $session 2>/dev/null 
        }

        function fullscreen() {
          smug start fullscreen
        } 

        function window() {
          smug start window
        } 
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

  launchd = if isDarwin then {
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
  } else {
    enable = false ;
  };

  xdg = {
    enable = true;
    configFile = {
      # "gcloud/configurations/config_default" = {
      #  text = builtins.readFile ./config/gcloud/config_default ;
      #};
      "smug" = {
          source = ./config/smug;
          recursive = true;
      };
      "nvim" = {
        source = ./config/nvim;
        recursive = true ;
      };

      "ssh/config.d" = {
        source = ./config/ssh/config.d;
        recursive = true;
      };
    } // lib.optionalAttrs isDarwin { 
      "karabiner/karabiner.json" = {
        text = builtins.readFile ./config/karabiner/karabiner.json ;
      };
    } // lib.optionalAttrs isLinux { 
      "glow/glow.yml" = {
        text = builtins.readFile ./config/glow/glow.yml ;
      };
    };
  };
}
