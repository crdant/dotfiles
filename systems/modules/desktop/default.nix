{ config, pkgs, lib, options, ...}:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;

  supportsHomebrew = builtins.hasAttr "homebrew" options;
  homebrewConfig = lib.optionalAttrs supportsHomebrew {
    homebrew = {
      enable = true;
      # updates homebrew packages on activation,
      onActivation = {
        autoUpdate = true;
        upgrade = true;
      };
      
      casks = [
        "displaybuddy"
        "font-cabin"
        "font-noto-sans"
        "ghostty@tip"
        "google-drive"
        "hammerspoon"
        "noun-project"
        "popclip"
        "proxyman"
        "quicklook-json"
        "rancher"
        "tailscale-app"
      ];

      masApps = {
       # "1Blocker" = 1365531024;
       "1Password for Safari" = 1569813296;
       "Amphetamine" = 937984704;
       "Ghostery Privacy Ad Blocker" = 6504861501;
       "iMovie" = 408981434;
       "Kagi for Safari" = 1622835804;
       "Keynote" = 409183694;
       "Microsoft Excel" = 462058435;
       "Microsoft PowerPoint" = 462062816;
       "Microsoft Remote Desktop" = 1295203466;
       "Microsoft Word" = 462054704;
       "Numbers" = 409203825;
       "Pages" = 409201541;
       "Todoist" = 585829637;
       "Transmit" = 1436522307;
      };
    };
  };

  supportsDesktopManager = builtins.hasAttr "services" options && builtins.hasAttr "desktopManager" options.services;
  desktopSessionConfig = lib.optionalAttrs supportsDesktopManager {
    services = {
      # GNOME as the baseline session, COSMIC as an alternate, both through GDM
      displayManager.gdm.enable = true;
      desktopManager = {
        gnome.enable = true;
        cosmic.enable = true;
      };

      # Defaults only: nixos-apple-silicon ships its own PipeWire tuning
      pipewire = {
        enable = lib.mkDefault true;
        alsa.enable = lib.mkDefault true;
        pulse.enable = lib.mkDefault true;
      };
    };
  };

  supportsNetworkManager = builtins.hasAttr "networking" options && builtins.hasAttr "networkmanager" options.networking;
  networkManagerConfig = lib.optionalAttrs supportsNetworkManager {
    networking.networkmanager.enable = lib.mkDefault true;
    # system-defaults turns on networkd for headless hosts; on a desktop
    # NetworkManager owns the interfaces, so stand networkd down unless the
    # host opts back out of NetworkManager
    networking.useNetworkd = lib.mkIf config.networking.networkmanager.enable (lib.mkForce false);
    systemd.network.enable = lib.mkIf config.networking.networkmanager.enable (lib.mkForce false);
  };
in (lib.mkMerge [
  {
    # Desktop applications and fonts for GUI environments
    documentation.enable = true;

    environment = {
      systemPackages = with pkgs; [
      ] ++ lib.optionals isDarwin [
        unstable._1password-gui
        chatgpt
        espanso
        firefox
        google-chrome
        open-sans
        slack
        zoom-us
      ] ++ lib.optionals isDarwin [
        unstable.bartender
        duti
        grandperspective
        hexfiend
        raycast
      ];
    }; 
   
    fonts = {
      packages = with pkgs.nerd-fonts; [
        fira-code
        inconsolata
        noto
        bitstream-vera-sans-mono
      ];
    };

  }
  homebrewConfig
  desktopSessionConfig
  networkManagerConfig
  ])
