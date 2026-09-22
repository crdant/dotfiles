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
        "apparency"
        "displaybuddy"
        "font-cabin"
        "font-noto-sans"
        "ghostty@tip"
        "google-drive"
        "hammerspoon"
        "noun-project"
        "popclip"
        "proxyman"
        "qlmarkdown"
        "quickjson"
        "suspicious-package"
        "tailscale-app"
      ];

      masApps = {
       "1Password for Safari" = 1569813296;
       "Amphetamine" = 937984704;
       "Ghostery Privacy Ad Blocker" = 6504861501;
       "iMovie" = 408981434;
       "Kagi for Safari" = 1622835804;
       "Keynote" = 361285480;
       "Microsoft Excel" = 462058435;
       "Microsoft PowerPoint" = 462062816;
       "Microsoft Remote Desktop" = 1295203466;
       "Microsoft Word" = 462054704;
       "Numbers" = 361304891;
       "Pages" = 361309726;
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
        firefox
      ] ++ lib.optionals isDarwin [
        unstable._1password-gui
        espanso
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
        jetbrains-mono
        noto
        bitstream-vera-sans-mono
      ];
    };

  }
  homebrewConfig
  desktopSessionConfig
  networkManagerConfig
  ])
