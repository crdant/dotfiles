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

    # Bartender 7 is only available as a macOS 27 beta, so nixpkgs still
    # ships Bartender 6. The beta zip nests the app under a build directory
    # alongside __MACOSX, so unpack without stripping the root and copy the
    # app out explicitly. Betas expire; bump the URL and hash from
    # https://www.macbartender.com/goldengate/releases/ and drop this once
    # nixpkgs packages a 7.x release.
    bartender = final.unstable.bartender.overrideAttrs (old: {
      version = "7.0.0-beta4";
      src = final.fetchzip {
        url = "https://downloads.macbartender.com/GoldenGate/bt7-beta4.zip";
        hash = "sha256-Xx59A6vPSCUtCDv0L+RjqEHOKTaGDvowJfvZwSJG2VQ=";
        stripRoot = false;
      };
      appName = "Bartender 7.app";
      installPhase = ''
        runHook preInstall

        mkdir -p "$out/Applications"
        cp -R "b7-b4/Bartender 7.app" "$out/Applications/"

        runHook postInstall
      '';
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
