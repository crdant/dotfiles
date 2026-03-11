{ pkgs, lib, options, ... }:
let
  supportsHomebrew = builtins.hasAttr "homebrew" options;
  homebrewConfig = lib.optionalAttrs supportsHomebrew {
    homebrew = {
      enable = true;
      taps = [
        "chainguard-dev/tap"
      ];
      brews = [
        "calicoctl"
        "chainguard-dev/tap/chainctl"
        "dagger"
      ];
      masApps = {
        "TestFlight" = 899247664;
        "Xcode" = 497799835;
      };
    };
  };
in (lib.mkMerge [
  {
    # Development tools and packages for software engineering workstations
    
    environment = {
      systemPackages = with pkgs; [
        git
        (python313.withPackages (ps: with ps; [
          pip
          setuptools
          wheel
          requests
          pyyaml
          click
          python-dateutil
        ]))
      ];
    };
  }

  homebrewConfig
]) 
