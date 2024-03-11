{ inputs, outputs, pkgs, ... }:
{
  imports = [
    ../darwin.nix 
  ];

  homebrew = {
    casks = [
      "gqrx"
      "vmware-fusion"
    ];

    masApps = {
     # "1Blocker" = 1365531024;
     "Freeze" = 1046095491;
     "Transmit" = 403388562;
    };
  };
} 
