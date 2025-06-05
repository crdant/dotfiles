{ pkgs ? import <nixpkgs> {}, }:

let
  unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
    inherit (pkgs) system;
  };
  # MLX is only supported on Apple Silicon, and I only use that with Darwin
  mlx = if pkgs.stdenv.isDarwin && pkgs.stdenv.isAarch64 then unstable.python312Packages.mlx else null;
  llm-echo = pkgs.callPackage ./llm-echo { python3 = customPython; };

  # Create a single, consistent Python environment
  # This ensures all packages use the exact same Python version

  customPython = unstable.python3.override {
    packageOverrides = self: super: {
      anthropic = unstable.python312Packages.anthropic.overrideAttrs (oldAttrs: let
          newVersion = "0.52.0";
        in {
          version = newVersion;
          src = unstable.fetchFromGitHub {
            owner = "anthropics";
            repo = "anthropic-sdk-python";
            rev = "v${newVersion}";
            hash = "sha256-GhWvR5s9qtmn1sctkCmfkp1HCWqw3SV56zlAIQcgIo8=";
          };
          nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ unstable.python312Packages.hatchling ];
        }
      );
 
      llm = unstable.python312Packages.llm.overrideAttrs (oldAttrs: let
          newVersion = "0.26";
        in {
          version = newVersion;
          src = unstable.fetchFromGitHub {
            owner = "simonw";
            repo = "llm";
            rev = newVersion;
            hash = "sha256-KTlNajuZrR0kBX3LatepsNM3PfRVsQn+evEfXTu6juE=";
          };
          patches = [ ./001-disable-install-uninstall-commands.patch ];

          # doCheck = false;
          dontUsePytestCheck = true;

          nativeCheckInputs = (oldAttrs.nativeCheckInputs or []) ++ [ llm-echo ];
        }
      );

      # Fix MLX by removing the obsolete Big Sur patch and using an older nanobind
      nanobind = unstable.python312Packages.nanobind.overrideAttrs (oldAttrs: {
        version = "2.4.0";
        src = unstable.fetchFromGitHub {
          owner = "wjakob";
          repo = "nanobind";
          rev = "v2.4.0";
          hash = "sha256-9OpDsjFEeJGtbti4Q9HHl78XaGf8M3lG4ukvHCMzyMU=";
          fetchSubmodules = true;
        };
      });
      mlx = if mlx != null then unstable.python312Packages.mlx.overrideAttrs (oldAttrs: let
        newVersion = "0.26.0";
      in {
        version = newVersion;
        src = unstable.fetchFromGitHub {
          owner = "ml-explore";
          repo = "mlx";
          rev = "v${newVersion}";
          hash = "sha256-rh4NEz4NGqNn5sN39aScOWHn62ajN0RIkowtxLj8bWk=";
        };

        # Remove the disable-accelerate.patch and add one of our own to make accelerate work
        patches = [] ;

        # Update SDK in buildInputs (keeping the original structure)
        buildInputs = (builtins.filter (dep: !(builtins.hasAttr "name" dep && dep.name or "" == "apple-sdk")) (oldAttrs.buildInputs or [])) ++ [
          pkgs.apple-sdk_15  # Replace the old SDK with SDK 15
        ];

        # Set environment for newer SDK
        preConfigure = (oldAttrs.preConfigure or "") + ''
          export SDKROOT="${pkgs.apple-sdk_15}/System/Library/Frameworks"
          export MACOSX_DEPLOYMENT_TARGET=15.0
        '';

        env = (oldAttrs.env or {}) // {
          PYPI_RELEASE = "0.26.0";
          # Replace -DMLX_BUILD_METAL=OFF with -DMLX_BUILD_METAL=ON in the existing CMAKE_ARGS
          CMAKE_ARGS = builtins.replaceStrings 
            ["-DMLX_BUILD_METAL=OFF"] 
            ["-DMLX_BUILD_METAL=ON"] 
            (oldAttrs.env.CMAKE_ARGS or "");
        };

        nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ 
          pkgs.apple-sdk_15
          pkgs.git
          pkgs.cacert
        ];

        propagatedBuildInputs = (oldAttrs.propagatedBuildInputs or []) ++ [
          self.nanobind  # Use our downgraded version
        ];
      }) else null;
      mlx-lm = if mlx != null then self.callPackage ./mlx-lm { python3 = customPython; } else null;
      
      llm-echo = llm-echo;
      groq = unstable.python312Packages.groq;
    };
    self = customPython;  # This makes it self-referential
  };
  
  # Now use this SAME customPython for all package definitions

  llm-anthropic = pkgs.callPackage ./llm-anthropic { python3 = customPython; };
  llm-fireworks = pkgs.callPackage ./llm-fireworks { python3 = customPython; };
  llm-gemini = pkgs.callPackage ./llm-gemini { python3 = customPython; };
  llm-groq = pkgs.callPackage ./llm-groq { python3 = customPython; };
  llm-mlx = pkgs.callPackage ./llm-mlx { python3 = customPython; };
  llm-perplexity = pkgs.callPackage ./llm-perplexity { python3 = customPython; };
  
  darwinPlugins = if pkgs.stdenv.isDarwin && pkgs.stdenv.isAarch64 && mlx != null then
    [ llm-mlx]
    else [];
  
  commonPlugins = [
    llm-anthropic
    llm-gemini
    llm-groq
    llm-perplexity
    llm-echo
    llm-fireworks
  ];

  # Combine all plugins
  allPlugins = commonPlugins ++ darwinPlugins;
  
  # Create the Python environment
  pythonEnv = customPython.withPackages (ps: [ customPython.pkgs.llm ] ++ allPlugins);
in
  pkgs.writeShellScriptBin "llm" ''
    exec ${pythonEnv}/bin/llm "$@"
  ''
