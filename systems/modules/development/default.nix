{ pkgs, lib, options, ... }:
let
  supportsHomebrew = builtins.hasAttr "homebrew" options;
  homebrewConfig = lib.optionalAttrs supportsHomebrew {
    homebrew = {
      enable = true;
      brews = [
        "calicoctl"
        "dagger"
        "lima"
      ];
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
