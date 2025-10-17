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
      dockutil
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

  # Dock configuration for Darwin
  home.activation = lib.mkIf isDarwin {
    configureDock = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Configuring Dock..."

      # Clear existing dock items
      ${pkgs.dockutil}/bin/dockutil --remove all --no-restart

      # Third-party applications (in /Applications/)
      ${pkgs.dockutil}/bin/dockutil --add "/Applications/Ghostty.app" --no-restart
      ${pkgs.dockutil}/bin/dockutil --add "/Applications/Arc.app" --no-restart
      ${pkgs.dockutil}/bin/dockutil --add "/Applications/Slack.app" --no-restart
      ${pkgs.dockutil}/bin/dockutil --add "/Applications/Superhuman.app" --no-restart
      ${pkgs.dockutil}/bin/dockutil --add "/Applications/zoom.us.app" --no-restart
      ${pkgs.dockutil}/bin/dockutil --add "/Applications/Twitter.app" --no-restart

      # System applications
      ${pkgs.dockutil}/bin/dockutil --add "/System/Applications/Messages.app" --no-restart
      ${pkgs.dockutil}/bin/dockutil --add "/System/Applications/Contacts.app" --no-restart

      # Productivity apps
      ${pkgs.dockutil}/bin/dockutil --add "/Applications/Todoist.app" --no-restart
      ${pkgs.dockutil}/bin/dockutil --add "/Applications/Bear.app" --no-restart

      # Media apps
      ${pkgs.dockutil}/bin/dockutil --add "/System/Applications/News.app" --no-restart
      ${pkgs.dockutil}/bin/dockutil --add "/System/Applications/Music.app" --no-restart
      ${pkgs.dockutil}/bin/dockutil --add "/System/Applications/TV.app" --no-restart
      ${pkgs.dockutil}/bin/dockutil --add "/System/Applications/Books.app" --no-restart
      ${pkgs.dockutil}/bin/dockutil --add "/System/Applications/Photos.app" --no-restart

      # iWork suite
      ${pkgs.dockutil}/bin/dockutil --add "/Applications/Keynote.app" --no-restart
      ${pkgs.dockutil}/bin/dockutil --add "/Applications/Numbers.app" --no-restart
      ${pkgs.dockutil}/bin/dockutil --add "/Applications/Pages.app" --no-restart

      # System utilities
      ${pkgs.dockutil}/bin/dockutil --add "/System/Applications/App Store.app" --no-restart
      ${pkgs.dockutil}/bin/dockutil --add "/System/Applications/Utilities/Activity Monitor.app" --no-restart
      ${pkgs.dockutil}/bin/dockutil --add "/System/Applications/Utilities/Console.app" --no-restart
      ${pkgs.dockutil}/bin/dockutil --add "/System/Applications/System Settings.app" --no-restart

      # Restart Dock to apply changes
      killall Dock

      echo "Dock configuration complete"
    '';
  };
}

