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
      # GNOME through GDM. COSMIC was briefly an alternate session, but its
      # settings panels flood the app grid with launchers — one desktop is
      # enough.
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;

      # Defaults only: nixos-apple-silicon ships its own PipeWire tuning
      pipewire = {
        enable = lib.mkDefault true;
        alsa.enable = lib.mkDefault true;
        pulse.enable = lib.mkDefault true;
      };
    };

    # Stock apps that will never see use: Zen is the browser, Neovim the
    # editor, and Ghostty the only terminal
    environment.gnome.excludePackages = with pkgs; [
      epiphany
      gnome-console
      gnome-text-editor
      gnome-tour
    ];

    # The NixOS module rather than the bare package: 1Password's system
    # authentication and browser integration need its polkit policy installed
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "crdant" ];
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
        # on Linux the browser seat belongs to Zen, from the home config
        firefox
        unstable._1password-gui
        chatgpt
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
        noto
        bitstream-vera-sans-mono
      ];
    };

  }
  homebrewConfig
  desktopSessionConfig
  networkManagerConfig
  ])
