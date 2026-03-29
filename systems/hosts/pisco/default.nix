{ inputs, outputs, pkgs, ... }:
{
  imports = [
    ../../roles/jumpbox.nix
  ];

  homebrew = {
    casks = [
      "webex"
    ];
  };
} 
