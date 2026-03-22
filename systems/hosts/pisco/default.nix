{ inputs, outputs, pkgs, ... }:
{
  imports = [
    ../../roles/jumpbox.nix
  ];

  users = {
    knownGroups = [ "nanoclaw" "openclaw" ];
    groups = {
      nanoclaw = {
        members = [ "crdant" "dewey" ];
      };
      openclaw = {
        members = [ "crdant" "luca" ];
      };
    };
  };

  homebrew = {
    casks = [
      "webex"
    ];
  };
} 
