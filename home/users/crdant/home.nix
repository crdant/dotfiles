{ inputs, outputs, config, pkgs, lib, username, homeDirectory, gitEmail, profile, ... }:

{
  # Import the full profile by default
  imports = [
    ../../profiles/${profile}.nix
  ];
  
  # Set user-specific secrets file for modules to use
  _module.args.secretsFile = ./secrets.yaml;
}
