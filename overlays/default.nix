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
    
    tailscale = (prev.tailscale.overrideAttrs (oldAttrs: let 
      newVersion = "1.84.2";
    in {
      version = newVersion;
      src = prev.fetchFromGitHub {
        owner = "tailscale";
        repo = "tailscale";
        rev = "v${newVersion}";
        sha256 = "sha256-dSYophk7oogLmlRBr05Quhx+iMUuJU2VXhAZVtJLTts=";
      };
      vendorHash = "sha256-QBYCMOWQOBCt+69NtJtluhTZIOiBWcQ78M9Gbki6bN0=";
      doCheck = false; # Disable tests due to undefined symbols in v1.84.2
    }));
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
