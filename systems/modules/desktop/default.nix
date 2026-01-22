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
        "font-cabin"
        "font-noto-sans"
        "ghostty@tip"
        "google-drive"
        "hammerspoon"
        "noun-project"
        "proxyman"
        "quicklook-json"
        "rancher"
      ];

      masApps = {
       # "1Blocker" = 1365531024;
       "1Password for Safari" = 1569813296;
       "Amphetamine" = 937984704;
       "Keynote" = 409183694;
       "Microsoft Excel" = 462058435;
       "Microsoft PowerPoint" = 462062816;
       "Microsoft Remote Desktop" = 1295203466;
       "Numbers" = 409203825;
       "Pages" = 409201541;
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
      systemPackages = with pkgs; lib.optionals isDarwin [
        espanso
        firefox
        google-chrome
        open-sans
        slack
        zoom-us
      ] ++ lib.optionals isDarwin [
        bartender
        duti
        grandperspective
        hexfiend
        pinentry_mac
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
