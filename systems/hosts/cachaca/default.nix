{ inputs, outputs, pkgs, ... }:
{
  imports = [
    ../../roles/workstation.nix 
  ];

  nix.enable = false;

  homebrew = {
    casks = [
      "webex"
    ];
  };

} 
