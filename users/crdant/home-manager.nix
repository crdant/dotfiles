{ config, pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin ;
  isLinux = pkgs.stdenv.isLinux ;

in {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.

  home = {
    homeDirectory = lib.mkForce "/Users/chuck";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "23.11";

    # specify variables to use in all logins across shells
    sessionVariables = {
      EDITOR = "nvim" ;
      VISUAL = "nvim" ;
      NIXPKGS_ALLOW_UNFREE = 1;
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
      awscli2
      atuin
      azure-cli
      certbot-full
      cloudflared
      conftest
      cosign
      crane
      cue
      exercism
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
      procps
      pstree
      rar
      ripgrep
      shellcheck
      sipcalc
      skopeo
      sops
      step-cli
      syft
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
      # postman
      # vscode
    ] ++ lib.optionals isLinux [
      _1password
      _1password-gui-beta
      coreutils
      dogdns
      gist
      glow
      gmailctl
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
      ripgrep
      sipcalc
      tailscale
      tcptraceroute
      yq-go
      zsh-completions
    ];

    file = {
      # can't quite configure gnupg the way I want within programs.gnupg
      ".gnupg" = {
        source = ./config/gnupg;
        recursive = true;
      };
      ".config/nvim/spell" = {
        source = ./config/nvim/spell;
        recursive = true ;
      };
     };
  };

  # Let Home Manager install and manage itself.
  programs = {
    direnv = {
      enable = true ;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    }; 

    fzf = {
      enable = true;
      enableZshIntegration = false;
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
      userEmail = "chuck@crdant.io";

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

          # If git uses `ssh` from Nix the macOS-specific configuration in
          # `~/.ssh/config` won't be seen as valid
          # https://github.com/NixOS/nixpkgs/issues/15686#issuecomment-865928923
          sshCommand = "/usr/bin/ssh";

          whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
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

        };

        init = {
          defaultBranch = "main";
        };

        diff = {
          plist = {
            textconv = "plutil -p";
          };
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
        if vim.fn.has('gui_vimr') == 1 then
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
          "gpg-agent"
          "tmux"
          "emoji"
          "gcloud"
          "aws"
          "kubectl"
          "helm"
          "history-substring-search"
          "velero"
          "terraform"
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
      '';

      initExtraBeforeCompInit = ''
        fpath+=($HOME/workspce/oh-my-zsh-custom/completions)
      '';

      envExtra = ''
        [[ $os == "darwin" ]] && export CERTBOT_ROOT=$(brew --prefix)/etc/certbot

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
    };

  };

}
