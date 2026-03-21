{ inputs, outputs, config, pkgs, lib, username, homeDirectory, gitEmail, profile, ... }:

{
  imports = [
    ../../profiles/${profile}.nix
  ];
}
