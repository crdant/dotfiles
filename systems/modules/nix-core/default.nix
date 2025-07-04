{
  inputs,
  outputs,
  pkgs, 
  lib,
  ... 
}: {
  # Core Nix configuration - absolute minimum for Nix to function
  
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
}