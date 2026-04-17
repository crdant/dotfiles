{ pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
in {
  homebrew = lib.mkIf isDarwin {
    casks = [
      "obsidian"
    ];
    masApps = {
      "Obsidian Web Clipper" = 6720708363;
    };
  };

  users.groups = {
    obsidian = {
      # Read/write access to obsidian vaults
    };
    obsidian-readonly = {
      # Read-only access to obsidian vaults
    };
  };
}
