{ inputs, outputs, config, pkgs, lib, username, homeDirectory, gitEmail, profile, hostname ? null, ... }:

{
  # Import the full profile by default, plus host-specific overrides when
  # building a "user@host" configuration
  imports = [
    ../../profiles/${profile}.nix
  ] ++ lib.optional (hostname != null && builtins.pathExists (./. + "/${hostname}.nix"))
    (./. + "/${hostname}.nix");
  
  # Set user-specific secrets file for modules to use
  _module.args.secretsFile = ./secrets.yaml;
}
