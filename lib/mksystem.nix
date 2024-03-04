# This function creates a NixOS system based on our VM setup for a
# particular architecture.
{ nixpkgs, inputs, }:

name:
{
  system,
  username,
  darwin ? false,
}:

let
  # make sure home directory and shell are specified
  # The config files for this system.
  hostConfig = ../hosts/${name};
  usernameConfig = ../users/crdant/${username}.nix;
  userHomeManagerConfig = ../users/crdant/home-manager.nix;

  # NixOS vs nix-darwin functionst
  systemFunc = if darwin then inputs.darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  home-manager = if darwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;
in systemFunc rec {
  inherit system;

  modules = [
    hostConfig
    usernameConfig 

    home-manager.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${username} = import userHomeManagerConfig ;
    }

  ];
}
