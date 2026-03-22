{ inputs, outputs, config, pkgs, lib, username, homeDirectory, gitEmail, profile, ... }:

{
  # Import the full profile by default
  imports = [
    ../../profiles/${profile}.nix
  ];
}
