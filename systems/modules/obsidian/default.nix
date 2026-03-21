{ pkgs, lib, config, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  users.groups = {
    obsidian = {
      # Read/write access to obsidian vaults
    };
    obsidian-readonly = {
      # Read-only access to obsidian vaults
    };
  };
}
