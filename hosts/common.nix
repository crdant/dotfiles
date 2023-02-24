{ pkgs, ... }:
{

  # Make sure the nix daemon always runs
  nix.useDaemon = true ;

  # assure flakes and nix command are enabled
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # zshrc sourcing needed environment changes
  programs.zsh.enable = true;
  programs.zsh.shellInit = ''
    # Nix
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
      . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
    # End Nix
    '';

  # fishrc sourcing needed environment changes
  programs.fish.enable = true;
  programs.fish.shellInit = ''
    # Nix
    if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
      source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
    end
    # End Nix
    '';	
  # bash is enabled by default

  environment = {
    systemPackages = with pkgs; [
      _1password
      coreutils
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
      knot-dns
      m-cli
      mas
      nmap
      opensc
      powershell
      pinentry_mac
      procps
      pstree
      ripgrep
      sipcalc
      # slack
      tailscale
      tcptraceroute
      timg
      tmux
      tree
      wget
      yq
      # zoom-us
      zsh-completions
    ] ++ lib.optionals pkgs.stdenv.isDarwin [
      # gui apps
      # _1password-gui-beta
      # transmission
      neovide
    ];

    shells = with pkgs; [ 
      bashInteractive
      fish
      powershell
      zsh
    ];

  };

  users = {
    users.crdant = {
      description = "Chuck D'Antonio";
      home = "/Users/crdant";
    };
  };

}
