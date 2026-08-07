{ pkgs, lib, options, ...}:

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
        "rancher"
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
  ])
