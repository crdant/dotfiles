# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    go1_26 = prev.go.overrideAttrs (oldAttrs: let
      newVersion = "1.26.4";
      in {
        version = newVersion;
        src = prev.fetchzip {
          url = "https://go.dev/dl/go${newVersion}.src.tar.gz";
          hash = "sha256-R16Z1k4oBCRWy5MKnOILcQtXhlCpSxdNsQMaLFRML0U=";
        };
        patches = [];
        env = (oldAttrs.env or {}) // {
          GOROOT_BOOTSTRAP = "${prev.go}/share/go";
        };
      }
    );

    buildGo1_26Module = prev.buildGoModule.override {
      go = final.go1_26;
    };

    replicated = prev.replicated.override {
      buildGoModule = final.buildGo1_26Module;
    };

    kots = prev.kots.override {
      buildGoModule = final.buildGo1_26Module;
    };

    direnv = final.unstable.direnv;

    fish = final.unstable.fish;

    mas = final.unstable.mas;

    bartender = prev.bartender.overrideAttrs (_oldAttrs: {
      version = "6.5.2";

      src = prev.fetchurl {
        url = "https://downloads.macbartender.com/B2/updates/B6Latest/Bartender%206.dmg";
        hash = "sha256-FVBgOJJYtabYXIUcbZgtsqJe5syV1HRcDfbZ8UkbJIQ=";
      };

      # undmg doesn't support APFS DMGs; use hdiutil directly instead
      unpackCmd = ''
        mnt=$(TMPDIR=/tmp mktemp -d -t nix-XXXXXXXXXX)
        function finish { /usr/bin/hdiutil detach "$mnt" -force; rm -rf "$mnt"; }
        trap finish EXIT
        /usr/bin/hdiutil attach -nobrowse -mountpoint "$mnt" "$curSrc"
        cp -a "$mnt/Bartender 6.app" "$PWD/"
      '';

      sourceRoot = ".";

      installPhase = ''
        runHook preInstall
        mkdir -p "$out/Applications"
        cp -r "Bartender 6.app" "$out/Applications/"
        runHook postInstall
      '';
    });

    container = prev.container.overrideAttrs (oldAttrs: rec {
      version = "0.10.0";
      src = prev.fetchurl {
        url = "https://github.com/apple/container/releases/download/${version}/container-${version}-installer-signed.pkg";
        hash = "sha256-xIHONVUk0DbDzdrH/SgeMXlNQGkL+aIfcy7z12+p/gg=";
      };
    });

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

}
