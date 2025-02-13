{
  inputs,
  outputs,
  pkgs, 
  ... 
}: {

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

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
      _1password-cli
      unstable.age
      coreutils
      dogdns
      gist
      git
      glow
      gnupg
      home-manager
      hostess
      inetutils
      jq
      knot-dns
      nmap
      neovim
      opensc
      openssh
      powershell
      procps
      pstree
      python3
      python311Packages.requests
      python311Packages.pip
      ripgrep
      sipcalc
      tailscale
      tcptraceroute
      timg
      tmux
      tree
      virtualenv
      wget
      yq-go
      yubico-pam
      zsh-completions
    ] ++ lib.optionals pkgs.stdenv.isLinux [
      espanso
    ];

    shells = with pkgs; [ 
      bashInteractive
      fish
      powershell
      zsh
    ];

  };

  users = {
    users.crdant = {};
    groups = {
      crdant = {
        gid = 1002;
      };
      ssher = {
        gid = 1001;
      };
    };
  };

}
