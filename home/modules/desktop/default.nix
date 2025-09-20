{ inputs, outputs, config, pkgs, lib, username, homeDirectory, secretsFile ? null, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Home Manager basics
  home = {
    # Basic packages for all environments
    packages = with pkgs; [
      _1password-gui
      _1password-cli
      neovide
    ] ++ lib.optionals isDarwin [
      iterm2
      vimr
      (callPackage ./vimr-wrapper.nix { inherit config; })
    ] ++ lib.optionals isLinux [
      obsidian
    ];

    file = {
    } // lib.optionalAttrs isDarwin {
      ".hammerspoon" = {
        source = ./config/hammerspoon;
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
    # Core Neovim configuration
    neovim = {
      # Core Lua config (basic settings, keymaps, etc.)
      extraLuaConfig = ''
        -- Appearance
        if vim.fn.has('gui_running') == 1 then
          vim.opt.background = "light"
        end
      '';
    };
  };
  
  xdg = {
    enable = true;
    configFile = {
    } // lib.optionalAttrs isDarwin { 
      "karabiner/karabiner.json" = {
        text = builtins.readFile ./config/karabiner/karabiner.json;
      };
      "ghostty/config" = {
        source = ./config/ghostty/config;
      };
    };
  };
}

