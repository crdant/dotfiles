# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    go1_26 = prev.go.overrideAttrs (oldAttrs: let
      newVersion = "1.26.1";
      in {
        version = newVersion;
        src = prev.fetchzip {
          url = "https://go.dev/dl/go${newVersion}.src.tar.gz";
          hash = "sha256-639cg0AQx1yKpkJtMI6/34miHPkKHHBfZV1yz3zWp2Y=";
        };
        patches = [];
        GOROOT_BOOTSTRAP = "${prev.go}/share/go";
      }
    );

    buildGo1_26Module = prev.buildGoModule.override {
      go = final.go1_26;
    };

    replicated = prev.replicated.override {
      buildGoModule = final.buildGo1_26Module;
    };

    direnv = final.unstable.direnv;

    mas = final.unstable.mas;

    container = prev.container.overrideAttrs (oldAttrs: rec {
      version = "0.10.0";
      src = prev.fetchurl {
        url = "https://github.com/apple/container/releases/download/${version}/container-${version}-installer-signed.pkg";
        hash = "sha256-xIHONVUk0DbDzdrH/SgeMXlNQGkL+aIfcy7z12+p/gg=";
      };
    });

    vimPlugins = prev.vimPlugins // {
      # xcodebuild-nvim = prev.callPackage ./xcodebuild-nvim { };
    };

    python3Packages = prev.python3Packages // {
      exa-py = prev.callPackage ./exa-py { };
      mlx-lm = prev.callPackage ./mlx-lm { };
    };
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };

  nur-packages = final: prev: {
    nur = import inputs.nur {
      pkgs = final;
      system = final.stdenv.hostPlatform.system;
    };
  };
}
