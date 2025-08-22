{ pkgs ? import <nixpkgs> {}, }:

let
  unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
    inherit (pkgs) system;
  };
  # MLX is only supported on Apple Silicon, and I only use that with Darwin
  mlx = if pkgs.stdenv.isDarwin && pkgs.stdenv.isAarch64 then unstable.python312Packages.mlx else null;
  llmPlugins = pkgs.llmPlugins;

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
      groq = unstable.python312Packages.groq;
    };
    self = customPython;  # This makes it self-referential
  };
  
  # Now use this SAME customPython for all package definitions
  darwinPlugins = if pkgs.stdenv.isDarwin && pkgs.stdenv.isAarch64 && mlx != null then
    [ llmPlugins.llm-mlx ]
    else [];
  
  modelPlugins = [
    llmPlugins.llm-anthropic
    llmPlugins.llm-gemini
    llmPlugins.llm-groq
    llmPlugins.llm-perplexity
    llmPlugins.llm-fireworks
    llmPlugins.llm-echo
  ];

  utilityPlugins = [
    llmPlugins.llm-cmd
    # llmPlugins.llm-cmd-comp
    llmPlugins.llm-jq
    llmPlugins.llm-python
  ];
  
  fragmentPlugins = [
    # llmPlugins.llm-fragments-site-text
  ]; 
  
  templatePlugins = [
    llmPlugins.llm-templates-fabric
  ];
    
  toolPlugins = [
    llmPlugins.llm-tools-simpleeval
    llmPlugins.llm-tools-quickjs
    llmPlugins.llm-tools-exa
    # llmPlugins.llm-tools-rag
  ];

  # fetch shell completion files from the llm-cmd-comp repository
  fishCompletions = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/CGamesPlay/llm-cmd-comp/refs/heads/main/share/llm-cmd-comp.fish";
    sha256 = "sha256-zaYOxlYxEUYySc4NUx1tklPm2FBxlr1HKaYlGhlznpA=";
  };
  
  zshCompletions = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/CGamesPlay/llm-cmd-comp/refs/heads/main/share/llm-cmd-comp.zsh";
    sha256 = "sha256-mVx+BZPxmNo+zwA4DDFQw6EfsM53QOLAvUgwO4wugOI=";
  };
  
  bashCompletions = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/CGamesPlay/llm-cmd-comp/refs/heads/main/share/llm-cmd-comp.bash";
    sha256 = "sha256-oWb0ZOV7yH9NGfyPUG7R5itTB0IC43nJlJGdnin++B0=";
  };

  # Combine all plugins
  allPlugins = modelPlugins ++ utilityPlugins ++ templatePlugins ++ fragmentPlugins ++ toolPlugins ; #++ darwinPlugins;
  
  # Create the Python environment
  pythonEnv = customPython.withPackages (ps: [ customPython.pkgs.llm ] ++ allPlugins);

in
  pkgs.stdenv.mkDerivation {
    name = "llm";
    version = "0.26";
    dontUnpack = true;

    nativeBuildInputs = [
      pkgs.installShellFiles
      pkgs.makeWrapper
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/bin"
      makeWrapper ${pythonEnv}/bin/llm $out/bin/llm
      runHook postInstall
    '';

    postInstall = ''
      installShellCompletion $fishCompletions $zshCompletions $bashCompletions
    '';
  }
