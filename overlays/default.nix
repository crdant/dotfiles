# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    direnv = final.unstable.direnv;

    # fish 4.8 stopped installing share/fish/tools — everything but man pages
    # now lives inside the binary, retrievable with `status get-file`. The
    # NixOS and Home Manager 26.05 fish modules still read the man-page
    # completion generator from the old path, so extract it and put it back.
    # Drop once the release branches pick up the `status get-file` module
    # fixes that are already on master (home-manager PR #9555, nixpkgs
    # PR #534907).
    fish = final.unstable.fish.overrideAttrs (oldAttrs: {
      postInstall = (oldAttrs.postInstall or "") + ''
        mkdir -p $out/share/fish/tools
        HOME=$(mktemp -d) $out/bin/fish --no-config \
          -c 'status get-file tools/create_manpage_completions.py' \
          > $out/share/fish/tools/create_manpage_completions.py
      '';
    });

    mas = final.unstable.mas;

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
