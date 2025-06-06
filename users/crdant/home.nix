{ inputs, outputs, config, pkgs, lib, username, homeDirectory, gitEmail, kind, ... }:

{
  # Import the full profile by default
  imports = [
    ./profiles/full.nix
  ];
  
  # Pass necessary parameters to the imported modules
  _module.args = {
    inherit inputs outputs username homeDirectory gitEmail kind;
  };
}