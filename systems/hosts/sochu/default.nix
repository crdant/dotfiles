{ inputs, outputs, pkgs, ... }:
{
  imports = [
    ../../profiles/workstation.nix
    ../../modules/development
  ];

  ids.gids.nixbld = 30000;

  homebrew = {
    casks = [
      "webex"
    ];
  };
} 
