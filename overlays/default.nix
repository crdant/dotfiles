# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    go1_25 = prev.go.overrideAttrs (oldAttrs: let
      newVersion = "1.25.1";
      in {
        version = newVersion;
        src = prev.fetchzip {
          url = "https://go.dev/dl/go${newVersion}.src.tar.gz";
          hash = "sha256-jz/CjhXI4jMFHhg7Up/X1FbUyMRTFM1fim3Gj77cU9Q=";
        };
        patches = [];
      }
    );

    buildGo1_25Module = prev.buildGoModule.override {
      go = final.go1_25;
    };

    vimPlugins = prev.vimPlugins // {
      nvim-aider = prev.callPackage ./nvim-aider { };
      # xcodebuild-nvim = prev.callPackage ./xcodebuild-nvim { }; 
    };

    python3Packages = prev.python3Packages // {
      exa-py = prev.callPackage ./exa-py { };
      mlx-lm = prev.callPackage ./mlx-lm { };
    };

    tailscale = (prev.tailscale.overrideAttrs (oldAttrs: let
      newVersion = "1.88.4";
    in {
      version = newVersion;
      src = prev.fetchFromGitHub {
        owner = "tailscale";
        repo = "tailscale";
        rev = "v${newVersion}";
        sha256 = "sha256-fzJwRTB2U2GuLmv1XUSMLnhyLlp+4kGorLGAvRVjDqw=";
      };
      vendorHash = "sha256-8aE6dWMkTLdWRD9WnLVSzpOQQh61voEnjZAJHtbGCSs=";
      doCheck = false;
    })).override{ buildGoModule = final.buildGo1_25Module; };

    kots = prev.kots.override{ buildGoModule = final.buildGo1_25Module; };

    claude-code = (prev.claude-code.overrideAttrs (oldAttrs: let
      newVersion = "2.0.21";
    in {
      version = newVersion;
      src = prev.fetchzip {
        url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${newVersion}.tgz";
        hash = "sha256-sX9btcy9uEHloAQNvCJFhwh0U/W14NWz2FjkdLXm1Q0=";
      };
    }));

    knot-dns = (prev.knot-dns.overrideAttrs (oldAttrs: {
      configureFlags = oldAttrs.configureFlags or [] ++ [
        "--enable-dnstap"
        "--enable-dnsssec"
        "--enable-gnutls"
      ];
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

  nur-packages = final: prev: {
    nur = import inputs.nur {
      pkgs = final;
      system = final.system;
    };
  };
}
