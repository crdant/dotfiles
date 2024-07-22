# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    iterm2 = prev.iterm2.overrideAttrs (oldAttrs: let
      newVersion = "3.5.3";
      in {
        version = newVersion;
        src = prev.fetchzip {
          url = "https://iterm2.com/downloads/stable/iTerm2-${prev.lib.replaceStrings ["."] ["_"] newVersion}.zip";
          hash = "sha256-uznoyXA3oGad88yZoVBJfLKMu8jK2PAKqwkpLq9fNzM=";
        };
      }
    );
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
