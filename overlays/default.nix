# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    vimPlugins = prev.vimPlugins // {
      nvim-aider = prev.callPackage ./nvim-aider { };
      # xcodebuild-nvim = prev.callPackage ./xcodebuild-nvim { }; 
    };

    python3Packages = prev.python3Packages // {
      exa-py = prev.callPackage ./exa-py { };
      mlx-lm = prev.callPackage ./mlx-lm { };
    };

    llm = prev.callPackage ./llm { };

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
