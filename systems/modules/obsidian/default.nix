{ pkgs, lib, options, ... }:

let
  supportsHomebrew = builtins.hasAttr "homebrew" options;
  homebrewConfig = lib.optionalAttrs supportsHomebrew {
    homebrew = {
      casks = [
        "obsidian"
      ];
      masApps = {
        "Obsidian Web Clipper" = 6720708363;
      };
    };
  };
in (lib.mkMerge [
  homebrewConfig
  {
    users.groups = {
      obsidian = {
        # Read/write access to obsidian vaults
      };
      obsidian-readonly = {
        # Read-only access to obsidian vaults
      };
    };
  }
])
