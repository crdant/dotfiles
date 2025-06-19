{ inputs, outputs, pkgs, ... }:
{
  imports = [
    ../../roles/workstation.nix
    ../../modules/development
  ];

  ids.gids.nixbld = 30000;

  homebrew = {
    casks = [
      "webex"
    ];
  };
} 
