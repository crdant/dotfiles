{ inputs, outputs, pkgs, ... }:
{
  ids.gids.nixbld = 30000;

  homebrew = {
    casks = [
      "webex"
    ];
  };
} 
