{ inputs, outputs, pkgs, ... }:
{
  imports = [
    ../../roles/workstation.nix 
  ];

  homebrew = {
    casks = [
      "gqrx"
    ];

    masApps = {
     # "1Blocker" = 1365531024;
     "Freeze" = 1046095491;
     "Transmit" = 403388562;
    };
  };
} 
