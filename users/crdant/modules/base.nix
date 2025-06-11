{ inputs, outputs, config, pkgs, lib, username, homeDirectory, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Home Manager basics
  home = {
    username = "${username}";
    homeDirectory = "${homeDirectory}";
    stateVersion = "23.11";

    # specify variables to use in all logins across shells
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      NIXPKGS_ALLOW_UNFREE = 1;
      NIXPKGS_ALLOW_BROKEN = 1;
    };

    sessionPath = [
      "$HOME/.local/bin" 
      "$HOME/workspace/go/bin"
    ] ++ lib.optionals isDarwin [
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
    ] ++ [
      "/usr/local/bin"
      "/usr/local/sbin"
    ]; 

    # Basic packages for all environments
    packages = with pkgs; [
      moreutils
      rar
      ripgrep
      smug
      unstable.tailscale
      zsh-completions
    ] ++ lib.optionals isDarwin [
      vimr
      (callPackage ../vimr-wrapper.nix { inherit config; })
    ] ++ lib.optionals isLinux [
      calicoctl
      coreutils
      dig
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
      snowsql
      unstable.tailscale
      tcptraceroute
      yq-go
      zsh-completions
    ];

    file = {
      ".curlrc" = {
        text = "-fL";
      };
      
      ".editorconfig" = {
        source = ../config/editorconfig;
      };
      
    } // lib.optionalAttrs isDarwin {
      ".hammerspoon" = {
        source = ../config/hammerspoon;
        recursive = true;
      };
      
      "Library/Application Support/espanso" = {
        source = ../config/espanso;
        recursive = true;
      };

      "Library/Colors/Solarized.clr" = {
        source = ../config/palettes/Solarized.clr;
        recursive = true;
      };
      
      "Library/Preferences/glow" = {
        source = ../config/glow;
        recursive = true;
      };
    };
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
  };

  # Essential programs
  programs = {
    home-manager.enable = true;
    
    atuin = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      flags = [
        "--disable-up-arrow"
      ];
    };
    
    direnv = {
      enable = true;
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
    
    tmux = {
      enable = true;
      keyMode = "vi";
      sensibleOnTop = true;
      terminal = "tmux-256color";
      
      plugins = [
        pkgs.tmuxPlugins.rose-pine
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
    
    zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
    
    zsh = {
      enable = true;
      enableCompletion = true;
      
      oh-my-zsh = {
        enable = true;
        custom = "$HOME/workspace/oh-my-zsh-custom";
        theme = "crdant";
        
        plugins = [ 
          "git"
          "gh"
          "tmux"
          "emoji"
          "history-substring-search"
          "ripgrep"
          "zoxide"
        ] ++ pkgs.lib.optionals isDarwin [
          "brew"
          "iterm2"
          "macos"
          "pasteboard"
        ];
      };
      
      localVariables = {
        COMPLETION_WAITING_DOTS = true;
      };
      
      shellAliases = {
        more = "less -X";
        pd = "pushd";
        pop = "popd";
        sha1 = "/usr/bin/openssl sha1";
        rmd160 = "/usr/bin/openssl rmd160";
        lsock = "sudo /usr/sbin/lsof -i -P";
        snowsql = "/Applications/SnowSQL.app/Contents/MacOS/snowsql";
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

        # handle SSH differences between Prompt on iOS and a machine with Yubikey PGP available
        # if we're connected via a traditional SSH agent it's probably Prompt
        GPG_AGENT_SSH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
        if [[ "SSH_AUTH_SOCK" != "$GPG_AGENT_SSH_SOCK" ]]; then
          # use ssh signing with the provided key
          export GIT_CONFIG_COUNT=3
          export GIT_CONFIG_KEY_0=gpg.format
          export GIT_CONFIG_VALUE_0=ssh
          export GIT_CONFIG_KEY_1=user.signingkey
          export GIT_CONFIG_VALUE_1=~/.ssh/id_charanda_enclave.pub
          export GIT_CONFIG_KEY_2=gpg.ssh.allowedSignersFile
          export GIT_CONFIG_VALUE_2=~/.config/git/allowed-signers
        fi

        # Tmux convenience functions
        function tmux-has-session() { 
          session=$1
          tmux has-session -t $session 2>/dev/null 
        }

        function smug-session() {
          session=$1
          if [[ ! -d "$XDG_RUNTIME_DIR/ssh" ]]; then
            mkdir -p "$XDG_RUNTIME_DIR/ssh"
          fi
          if [[ "SSH_AUTH_SOCK" != "$XDG_RUNTIME_DIR/ssh/s.ssh-agent.smug-$session" ]]; then
            ln -sf $(readlink -f $SSH_AUTH_SOCK) "$XDG_RUNTIME_DIR/ssh/s.ssh-agent.smug-$session"
            export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh/s.ssh-agent.smug-$session"
          fi
          smug start $session
        }

        function fullscreen() {
          smug-session fullscreen
        } 

        function window() {
          smug-session window
        } 
      '';
      
      initExtraBeforeCompInit = ''
        fpath+=($HOME/workspace/oh-my-zsh-custom/completions)
      '';
      
      envExtra = ''
        export XDG_CONFIG_HOME="${config.xdg.configHome}"
        
        # if rancher desktop is installed use it's binaries ONLY for anything not already
        # installed system-wide
        if [[ -d $HOME/.rd ]] ; then
          export PATH=$PATH:"$HOME/.rd/bin"
        fi
        
        # set default for Claude config based on hostname
        if [[ "$(whoami)" == "chuck" ]] ; then
          export CLAUDE_CONFIG_DIR="${config.xdg.configHome}/replicated"
        else
          export CLAUDE_CONFIG_DIR="${config.xdg.configHome}/personal"
        fi
        
        unset RPS1
      '';
    };

    # Core Neovim configuration
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      
      # Core plugins used everywhere
      plugins = with pkgs.vimPlugins; [
        editorconfig-nvim
        {
          plugin = rose-pine;
          config = ''
            let g:rose_pine_dark_variant = 'moon'
            let g:rose_pine_disable_background = 1 
            colorscheme rose-pine
          '';
        }
        vim-surround
        vim-commentary
        vim-repeat
        vim-speeddating
        vim-tmux-navigator
        zoxide-vim
      ];
      
      # Core Lua config (basic settings, keymaps, etc.)
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
          autocmd FocusLost * call feedkeys("\<esc>")
        ]]
        
        -- Basic indentation settings
        vim.opt.expandtab = true
        vim.opt.smarttab = true
        vim.opt.shiftwidth = 2
        vim.opt.tabstop = 2
        vim.opt.softtabstop = 2
        vim.opt.ai = true
        vim.opt.si = true
        
        -- dont use arrowkeys
        vim.api.nvim_set_keymap("n", "<UP>", "<NOP>", { noremap = true })
        vim.api.nvim_set_keymap("n", "<DOWN>", "<NOP>", { noremap = true })
        vim.api.nvim_set_keymap("n", "<LEFT>", "<NOP>", { noremap = true })
        vim.api.nvim_set_keymap("n", "<RIGHT>", "<NOP>", { noremap = true })
        
        -- really, just dont
        vim.api.nvim_set_keymap("i", "<UP>", "<NOP>", { noremap = true })
        vim.api.nvim_set_keymap("i", "<DOWN>", "<NOP>", { noremap = true })
        vim.api.nvim_set_keymap("i", "<LEFT>", "<NOP>", { noremap = true })
        vim.api.nvim_set_keymap("i", "<RIGHT>", "<NOP>", { noremap = true })
        
        -- Appearance
        if vim.fn.has('gui_running') == 1 then
          vim.opt.background = "light"
        end
        
        -- line numbers
        vim.opt.number = true
      '';
    };
  };
  
  sops = {
    defaultSopsFile = ../secrets.yaml;  # Path to your secrets file
    gnupg = {
      home = "${config.home.homeDirectory}/.gnupg";
    };
  };

  xdg = {
    enable = true;
    configFile = {
      "smug" = {
        source = ../config/smug;
        recursive = true;
      };

      "ssh/config.d" = {
        source = ../config/ssh/config.d;
        recursive = true;
      };
    } // lib.optionalAttrs isDarwin { 
      "karabiner/karabiner.json" = {
        text = builtins.readFile ../config/karabiner/karabiner.json;
      };
      "ghostty/config" = {
        source = ../config/ghostty/config;
      };
    } // lib.optionalAttrs isLinux { 
      "glow/glow.yml" = {
        text = builtins.readFile ../config/glow/glow.yml;
      };
    };
  };
}
