{ inputs, outputs, options, config, pkgs, lib, username, homeDirectory, secretsFile ? null, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  cfg = config.guiEnvironment;
  guiPath = config.guiPath;

  # the official Spotify client only ships for x86_64-linux and aarch64-darwin
  spotifyAvailable = lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.unstable.spotify;

  setenvScript =
    lib.optionalString (guiPath != [])
      "/bin/launchctl setenv PATH '${lib.concatStringsSep ":" guiPath}'\n" +
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: value:
        "/bin/launchctl setenv ${name} '${value}'"
      ) cfg
    );

  # Dock items in order, after Finder. Where an app lives depends on how it
  # was installed: Homebrew casks and the Mac App Store use /Applications,
  # nix-darwin copies system packages into /Applications/Nix Apps, and Apple
  # apps live under /System/Applications. Items that aren't installed on a
  # given host (e.g. Webex) are skipped.
  nixApps = "/Applications/Nix Apps";
  dockApps = [
    "/Applications/Ghostty.app"
    "/Applications/Claude.app"
    "/Applications/Dia.app"
    "${nixApps}/Slack.app"
    "/Applications/Superhuman.app"
    "/System/Applications/Messages.app"
    "${nixApps}/zoom.us.app"
    "/Applications/Microsoft Teams.app"
    "/Applications/Webex.app"
    "/Applications/Beeper Desktop.app"
    "/System/Applications/Contacts.app"
    "/Applications/Todoist.app"
    "/Applications/Obsidian.app"

    # Media
    "/System/Applications/News.app"
    "/System/Applications/Music.app"
    "/System/Applications/TV.app"
    "/System/Applications/Books.app"
    "/System/Applications/Photos.app"

    # iWork (the Mac App Store installs these under their Creator Studio names)
    "/Applications/Keynote Creator Studio.app"
    "/Applications/Numbers Creator Studio.app"
    "/Applications/Pages Creator Studio.app"

    # System utilities
    "/System/Applications/App Store.app"
    "/System/Applications/Utilities/Activity Monitor.app"
    "/System/Applications/Utilities/Console.app"
    "/System/Applications/Siri AI.app"
    "/System/Applications/System Settings.app"
  ];

  addToDock = app: ''
    if [ -e "${app}" ]; then
      ${pkgs.dockutil}/bin/dockutil --add "${app}" --no-restart
    else
      echo "Skipping missing Dock item: ${app}"
    fi
  '';

in {
  # Home Manager basics
  home = {
    # Basic packages for all environments
    packages = with pkgs; [
      neovide
    ] ++ lib.optionals spotifyAvailable [
      unstable.spotify
    ] ++ lib.optionals (!spotifyAvailable) [
      unstable.spotube
    ] ++ lib.optionals isDarwin [
      unstable.chatgpt
      dockutil
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
      initLua = ''
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

  # LaunchAgent to set GUI-visible environment variables on login
  launchd.agents.set-environment = lib.mkIf (isDarwin && (cfg != {} || guiPath != [])) {
    enable = true;
    config = {
      Label = "io.shortrib.set-environment";
      ProgramArguments = [
        "/bin/bash" "-c" setenvScript
      ];
      RunAtLoad = true;
    };
  };

  # Dock configuration for Darwin
  home.activation = lib.mkIf isDarwin {
    # Re-trigger the environment agent immediately on activation
    guiEnvironment = lib.mkIf (cfg != {} || guiPath != []) (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      /bin/launchctl kickstart -k gui/$(/usr/bin/id -u)/io.shortrib.set-environment 2>/dev/null || true
    '');

    configureDock = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Configuring Dock..."

      # Clear existing dock items
      ${pkgs.dockutil}/bin/dockutil --remove all --no-restart

      ${lib.concatMapStrings addToDock dockApps}

      # Restart Dock to apply changes
      /usr/bin/killall Dock

      echo "Dock configuration complete"
    '';
  };
  guiEnvironment = lib.mkIf (options ? guiEnvironment) {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
