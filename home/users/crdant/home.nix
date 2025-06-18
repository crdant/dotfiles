{ inputs, outputs, config, pkgs, lib, username, homeDirectory, gitEmail, ... }:

{
  # Import the full profile by default
  imports = [
    ../../profiles/full.nix
  ];
}
