{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = "crdant";
    homeDirectory = "/Users/crdant";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "22.11";

    # specify variables to use in all logins across shells
    sessionVariables = {
      EDITOR = "nvim" ;
      VISUAL = "nvim" ;
    };

    sessionPath = [
      "$HOME/.local/bin" 
      "$HOME/workspace/go/bin"
      "/usr/local/bin"
      "/usr/local/sbin"
    ] ++ lib.optionals pkgs.stdenv.isDarwin [
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
    ]; 
    
    # Specify packages not explicitly configured below
    packages = with pkgs; [
      argocd
      awscli2
      azure-cli
      certbot-full
      cloudflared
      conftest
      coreutils
      cosign
      crane
      cue
      dogdns
      exercism
      gist
      glow
      gmailctl
      gnupg
      govc
      hostess
      jq
      kubectl
      kubernetes-helm
      istioctl
      k0sctl
      kubeseal
      kustomize
      minikube
      minio-client
      nmap
      opensc
      oras
      packer
      procps
      pstree
      ripgrep
      sget
      shellcheck
      sipcalc
      skopeo
      sops
      step-cli
      tailscale
      tcptraceroute
      tektoncd-cli
      terraform
      timg
      tree
      vault
      wget
      ytt
      yq
      yubico-pam
      yubico-piv-tool
      yubikey-manager
      zsh-completions
    ] ++ lib.optionals stdenv.isDarwin [
      duti
      m-cli
      mas
      pinentry_mac
    ] ++ lib.optionals stdenv.isLinux [
      nerdctl
    ];

    file = {
      # can't quite configure gnupg the way I want within programs.gnupg
      ".gnupg" = {
        source = ./config/gnupg;
        recursive = true;
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
      defaultEditor = true ;
      viAlias = true;
      vimAlias = true;

      plugins = with pkgs.vimPlugins; [
        editorconfig-nvim
        NeoSolarized
        nvim-fzf
        nvim-surround
        vim-commentary
        vim-repeat
        zoxide-vim
      ];

      extraConfig = ''
        """""""""""""""""""""""""""""""""""""""""""""""
        " => General
        """""""""""""""""""""""""""""""""""""""""""""""

        set encoding=utf-8          " The encoding displayed
        set fileencoding=utf-8      " The encoding written to file
        syntax on                   " Enable syntax highlight
        set ttyfast                 " Faster redrawing
        set lazyredraw              " Only redraw when necessary
        set cursorline              " Find the current line quickly.

        " go to normal mode when the window loses focus
        autocmd FocusLost * call feedkeys("\<esc>")

        """""""""""""""""""""""""""""""""""""""""""""""
        " => Indentation
        """""""""""""""""""""""""""""""""""""""""""""""

        " Use spaces instead of tabs
        set expandtab

        " Be smart when using tabs ;)
        " :help smarttab
        set smarttab

        " 1 tab == 4 spaces
        set shiftwidth=2
        set tabstop=2
        set softtabstop=2

        " Auto indent
        " Copy the indentation from the previous line when starting a new line
        set ai

        " Smart indent
        " Automatically inserts one extra level of indentation in some cases, and works for C-like files
        set si

        """""""""""""""""""""""""""""""""""""""""""""""
        " => Keymappings
        """""""""""""""""""""""""""""""""""""""""""""""

        " dont use arrowkeys
        noremap <Up> <NOP>
        noremap <Down> <NOP>
        noremap <Left> <NOP>
        noremap <Right> <NOP>

        " really, just dont
        inoremap <Up>    <NOP>
        inoremap <Down>  <NOP>
        inoremap <Left>  <NOP>
        inoremap <Right> <NOP>

        " copy and paste to/from vIM and the clipboard
        nnoremap <C-y> +y
        vnoremap <C-y> +y
        nnoremap <C-p> +P
        vnoremap <C-p> +P

        " map fzf to ctrl+p
        nnoremap <C-P> :Files<CR>


        noremap <Up> <Nop>
        noremap <Down> <Nop>
        noremap <Left> <Nop>
        noremap <Right> <Nop>

        """"""""""""""""""""""""""""""""""""""""""""""
        " => Appearance
        """""""""""""""""""""""""""""""""""""""""""""""

        colorscheme NeoSolarized
        if has('gui_vimr')
          set background=light
        endif

        " line numbers
        " set relativenumber
        set number
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
          "git-flow"
          "gpg-agent"
          "tmux"
          "emoji"
          "docker"
          "aws"
          "minikube"
          "krew"
          "kubectl"
          "helm"
          "history-substring-search"
          "velero"
          "terraform"
          ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
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
        export GOVC_URL=https://vcenter.lab.shortrib.net
        export GOVC_USERNAME=administrator@shortrib.local
        export GOVC_PASSWORD=$(security find-generic-password -a administrator@shortrib.local -s vcenter.lab.shortrib.net -w)
        export GOVC_INSECURE=true
      '';

    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

  };

}
