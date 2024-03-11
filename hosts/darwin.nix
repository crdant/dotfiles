{ pkgs, ... }:
{

  documentation.enable = false ;

  imports = [
    ./common.nix
  ];

  security.pam.enableSudoTouchIdAuth = true;

  environment = {
    systemPackages = with pkgs; [
      iterm2
      raycast
    ];
  }; 
 
  homebrew = {
    enable = true;
    # updates homebrew packages on activation,
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
    
    taps = [
      "homebrew/bundle"
      "homebrew/cask"
      "homebrew/cask-drivers"
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
      "homebrew/core"
      "homebrew/services"
      "OJFord/formulae"
      "vmware-tanzu/carvel"
    ];

    brews = [
      "adr-tools"
      # "tccutil"
      "trash"
      "opa"
      "osxutils"
      "pinentry-mac"
      "watch"
      "pam_yubico"
      # "ojford/formulae/loginitems"
      "replicatedhq/replicated/cli"
      # "vmware-tanzu/carvel/imgpkg"
    ];

    casks = [
      "1password"
      "bartender"
      "carbon-copy-cloner"
      "dash"
      "espanso"
      "firefox"
      "font-bitstream-vera"
      "font-cabin"
      "font-fira-code"
      "font-inconsolata"
      "font-noto-sans"
      "font-open-sans"
      "google-chrome"
      "google-drive"
      "grandperspective"
      "hammerspoon"
      "hex-fiend"
      "jetbrains-toolbox"
      "noun-project"
      "obs"
      "proxyman"
      "quicklook-json"
      "rancher"
      "raspberry-pi-imager"
      "raycast"
      "superhuman"
      "tailscale"
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
