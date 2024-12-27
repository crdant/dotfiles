# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    go = prev.go.overrideAttrs (oldAttrs: let
      newVersion = "1.23.2";
      in {
        version = newVersion;
        src = prev.fetchzip {
          url = "https://go.dev/dl/go${newVersion}.src.tar.gz";
          hash = "sha256-ijAvBzFdarc4YICOUvPeSaCSjrjCqdNi451D8rge5gA=";
        };
      }
    );
    iterm2 = prev.iterm2.overrideAttrs (oldAttrs: let
      newVersion = "3.5.10";
      in {
        version = newVersion;
        src = prev.fetchzip {
          url = "https://iterm2.com/downloads/stable/iTerm2-${prev.lib.replaceStrings ["."] ["_"] newVersion}.zip";
          hash = "sha256-tvHAuHitB5Du8hqaBXmWzplrmaLF6QxV8SNsRyfCUfM=";
        };
      }
    );
    bruno = prev.bruno.overrideAttrs (oldAttrs: let
      newVersion = "1.25.0";
      in {
        version = newVersion;
        src = oldAttrs.src // { 
          rev = "v${newVersion}";
          hash = "sha256-mOE5RoEOlvI9C0i/pWOulRJTkUgvQITuq2hs7q/p3jo=";
        };
      }
    );
    buildGoModule = prev.buildGoModule.override {
      go = final.go;
    };
    vimPlugins = prev.vimPlugins // {
      supermaven-vim = prev.callPackage ./supermaven-nvim { };
    };
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
