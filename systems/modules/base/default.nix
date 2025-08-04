{ inputs, outputs, pkgs, lib, options, ... }: 
let
  isLinux = pkgs.stdenv.isLinux; 
  isDarwin = pkgs.stdenv.isDarwin;

  needsIntegerState = builtins.hasAttr "defaults" options.system;
  stateVersion = {
    stateVersion = if needsIntegerState then 5 else "24.11";
  };
in {
  system = lib.mkMerge [
    stateVersion
  ];

  imports = [
    ./terminfo.nix
  ];

  # assure flakes and nix command are enabled
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      '';

    registry = {
      nixpkgs-unstable = {
        from = {
          id = "nixpkgs";
          type = "indirect";
        };
        to = {
          owner = "NixOS";
          repo = "nixpkgs";
          type = "github";
          ref = "nixos-unstable";
        };
      };
    };
  };

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      outputs.overlays.nur-packages

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
    enableAllTerminfo = true;

    systemPackages = with pkgs; [
      coreutils
      glow
      gnumake
      gnupg
      home-manager
      hostess
      inetutils
      jq
      mtr
      neovim
      nh
      openssh
      ripgrep
      sipcalc
      tailscale
      tcptraceroute
      tmux
      tree
      wget
      yq-go
      yubico-pam
      zsh-completions
    ] ++ lib.optionals isDarwin [
      darwin.trash
    ];

    shells = with pkgs; [ 
      bashInteractive
      fish
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
  } // lib.optionalAttrs isLinux {
    users.crdant = {
      uid = 1001;
    };
  };

}
