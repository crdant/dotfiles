{ pkgs, lib, ... }:

let 
  supportsHomebrew = builtins.hasAttr "homebrew" options;
  homebrewConfig = lib.optionalAttrs supportsHomebrew {
    enable = true;
    # updates homebrew packages on activation,
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
    
    taps = [
      "homebrew/bundle"
      "homebrew/cask-drivers"
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
      "homebrew/services"
      "OJFord/formulae"
      "vmware-tanzu/carvel"
    ];

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
      "yubico-yubikey-manager"
    ];

    masApps = {
     # "1Blocker" = 1365531024;
     "1Password for Safari" = 1569813296;
     "Amphetamine" = 937984704;
     "Bear" = 1091189122;
     "Craft" = 1487937127;
     "Keynote" = 409183694;
     "Matter" = 1548677272;
     "Memory Clean 3" = 1302310792;
     "Microsoft Excel" = 462058435;
     "Microsoft PowerPoint" = 462062816;
     "Microsoft Remote Desktop" = 1295203466;
     "Numbers" = 409203825;
     "Pages" = 409201541;
     "Paprika Recipe Manager 3" = 1303222628;
     "PopClip" = 445189367;
     "Todoist" = 585829637;
     "Twitter" = 1482454543;
     "Transmit" = 403388562;
    };
  };
in (lib.mkMerge [

in {
  # Desktop applications and fonts for GUI environments
  
  documentation.enable = true;

  environment = {
    systemPackages = with pkgs; lib.optionals isDarwin [
      bartender
      duti
      espanso
      firefox
      google-chrome
      grandperspective
      hexfiend
      lima
      m-cli
      mas
      open-sans
      pinentry_mac
      raycast
      slack
      tailscale
      zoom-us
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

  homebrewConfig
  homebrew = lib.mkIf isDarwin {
    enable = true;
    # updates homebrew packages on activation,
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
    
    taps = [
      "homebrew/bundle"
      "homebrew/cask-drivers"
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
      "homebrew/services"
      "OJFord/formulae"
      "vmware-tanzu/carvel"
    ];

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
      "yubico-yubikey-manager"
    ];

    masApps = {
     # "1Blocker" = 1365531024;
     "1Password for Safari" = 1569813296;
     "Amphetamine" = 937984704;
     "Bear" = 1091189122;
     "Craft" = 1487937127;
     "Keynote" = 409183694;
     "Matter" = 1548677272;
     "Memory Clean 3" = 1302310792;
     "Microsoft Excel" = 462058435;
     "Microsoft PowerPoint" = 462062816;
     "Microsoft Remote Desktop" = 1295203466;
     "Numbers" = 409203825;
     "Pages" = 409201541;
     "Paprika Recipe Manager 3" = 1303222628;
     "PopClip" = 445189367;
     "Todoist" = 585829637;
     "Twitter" = 1482454543;
     "Transmit" = 403388562;
    };
  };
}
