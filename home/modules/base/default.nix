{ inputs, outputs, config, pkgs, lib, username, homeDirectory, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  imports = [ ./fish.nix ./zsh.nix ];

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
      dogdns
      moreutils
      nmap
      pstree
      rar
      ripgrep
      sipcalc
      smug
      tcptraceroute
      zsh-completions
    ] ++ lib.optionals isLinux [
      coreutils
      dig
      gnupg
      hostess
      jq
      opensc
      procps
      yq-go
    ] ++ lib.optionals isDarwin [
      icalpal
    ];

    file = {
      ".curlrc" = {
        text = "-fL";
      };
      
      ".editorconfig" = {
        source = ./config/editorconfig;
      };
      
    } // lib.optionalAttrs isDarwin {
      "Library/Preferences/glow" = {
        source = ./config/glow;
        recursive = true;
      };
    };

    activation = {
     workspaceDirectory = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
        mkdir -p ~/workspace
        mkdir -p ~/sandbox
      '';

      customizeOmz = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        if [ ! -d ~/workspace/oh-my-zsh-custom ]; then
          ${pkgs.git}/bin/git clone https://github.com/crdant/oh-my-zsh-custom ~/workspace/oh-my-zsh-custom || {
            echo "Warning: Failed to clone oh-my-zsh-custom repository. Skipping..."
          }
        else
          echo "oh-my-zsh-custom already exists, skipping clone"
        fi
      '';
    };

  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      outputs.overlays.nur-packages
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

    starship = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;

      # Layout mirrors the crdant oh-my-zsh theme: "user@host ➜ cwd git:(branch)"
      # Colors use ANSI names so Ghostty's Rose Pine Moon palette paints them.
      settings = {
        add_newline = false;
        format = "$username$hostname $character $directory $git_branch$git_state$git_status$line_break$jobs";

        username = {
          show_always = true;
          style_user = "magenta";
          style_root = "bold red";
          format = "[$user]($style)";
        };

        hostname = {
          ssh_only = false;
          style = "magenta";
          format = "[@$hostname]($style)";
        };

        character = {
          success_symbol = "[➜](bold red)";
          error_symbol = "[➜](bold red)";
        };

        directory = {
          style = "cyan";
          truncation_length = 3;
          truncate_to_repo = false;
        };

        git_branch = {
          symbol = "";
          style = "bold blue";
          format = "[git:\\(]($style)[$branch](red)[\\)]($style)";
        };

        git_status = {
          style = "bold yellow";
          format = " [$all_status$ahead_behind]($style)";
          conflicted = "✗";
          modified = "✗";
          untracked = "✗";
          staged = "●";
          renamed = "»";
          deleted = "✘";
        };
      };
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
        
        -- line numbers
        vim.opt.number = true
      '';
    };
  };
  
  xdg = {
    enable = true;
    configFile = {
      "smug" = {
        source = ./config/smug;
        recursive = true;
      };
    } // lib.optionalAttrs isDarwin { 
    } // lib.optionalAttrs isLinux { 
      "glow/glow.yml" = {
        text = builtins.readFile ./config/glow/glow.yml;
      };
    };
  };
}
