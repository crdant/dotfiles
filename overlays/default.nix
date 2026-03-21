# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    mas = final.unstable.mas;

    container = prev.container.overrideAttrs (oldAttrs: rec {
      version = "0.10.0";
      src = prev.fetchurl {
        url = "https://github.com/apple/container/releases/download/${version}/container-${version}-installer-signed.pkg";
        hash = "sha256-xIHONVUk0DbDzdrH/SgeMXlNQGkL+aIfcy7z12+p/gg=";
      };
    });

    vimPlugins = prev.vimPlugins // {
      nvim-aider = prev.callPackage ./nvim-aider { };
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
