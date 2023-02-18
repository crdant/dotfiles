{ pkgs, ... }:
{

  # Make sure the nix daemon always runs
  services.nix-daemon.enable = true;

  # Installs a version of nix, that dosen't need "experimental-features = nix-command flakes" in /etc/nix/nix.conf
  services.nix-daemon.package = pkgs.nixFlakes;
  
  # zshrc sourcing needed environment changes
  programs.zsh.enable = true;
  # bash is enabled by default

  environment = {
    systemPackages = with pkgs; [
      _1password
      _1password-gui-beta
      coreutils
      darwin-zsh-completions
      dogdns
      duti
      espanso
      gist
      glow
      gmailctl
      gnupg
      hostess
      iterm2
      jq
      karabiner-elements
      m-cli
      mas
      nmap
      opensc
      pinentry_mac
      procps
      pstree
      ripgrep
      sipcalc
      slack
      tailscale
      tcptraceroute
      timg
      tree
      wget
      yq
      zoom-us
      zsh-completions
    ];
  };

  homebrew = {
    enable = true;
    # updates homebrew packages on activation,
    autoUpdate = true;
    
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
      "knot"
      "tccutil"
      "trash"
      "opa"
      "osxcutils"
      "ojford/formulae/loginitems"
      "replicatedhq/replicated/cli"
      "vmware-tanzu/carvel/imgpkg"
    ];

    casks = [
      "bartender"
      "carbon-copy-cloner"
      "dash"
      "firefox"
      "font-bitstream-vera"
      "font-cabin"
      "font-fira-code"
      "font-inconsolata"
      "font-noto-sans"
      "font-open-sans"
      "github"
      "google-chrome"
      "google-drive"
      "gqrx"
      "grandperspective"
      "hammerspoon"
      "hex-fiend"
      "istumbler"
      "jetbrains-toolbox"
      "multipass"
      "noun-project"
      "obs"
      "parallels"
      "proxyman"
      "quicklook-json"
      "rancher"
      "raspberry-pi-imager"
      "raycast"
      "superhuman"
      "tailscale"
      "vimr"
      "vmware-fusion"
      "yubico-yubikey-piv-manager"
    ];

    masApps = [
     "1Blocker" = 1365531024;
     "1Password for Safari" = 1569813296;
     "Airmail" = 918858936;
     "Amphetamine" = 937984704;
     "Bear" = 1091189122;
     "Buffer" = 891953906;
     "Craft" = 1487937127;
     "Fantastical" = 975937182;
     "Freeze" = 1046095491;
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
     "Transmit" = 403388562;
     "Twitter" = 1482454543;
    ]
  };
}
