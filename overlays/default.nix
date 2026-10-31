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

    # nixpkgs still ships Bartender 6, which doesn't fully support macOS 27.
    # Bartender 7 releases moved to their own path, so the upstream src URL
    # doesn't follow the version bump. Take new versions from
    # https://downloads.macbartender.com/Bartender7/updates/AppcastB7.xml and
    # drop this once nixpkgs packages a 7.x release. Unpacking the zip writes
    # its macOS metadata out as ._* files inside the bundle, which breaks the
    # code signature, so remove them.
    bartender = final.unstable.bartender.overrideAttrs (finalAttrs: old: {
      version = "7.1.0";
      src = final.fetchzip {
        url = "https://downloads.macbartender.com/Bartender7/updates/${
          builtins.replaceStrings [ "." ] [ "-" ] finalAttrs.version
        }/Bartender%207.zip";
        hash = "sha256-CT0EVTDO5dR5rwNcNXWnnd8K6+4m1Ou3I3fywANcgaY=";
        postFetch = ''
          find "$out" -name '._*' -delete
        '';
      };
    });

    container = final.unstable.container;
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
