{ inputs, outputs, pkgs, ... }:
{
  imports = [
    ../../roles/workstation.nix 
  ];

  nix.enable = false ;

  homebrew = {
    casks = [
      "gqrx"
    ];

    masApps = {
     # "1Blocker" = 1365531024;
     "Freeze" = 1046095491;
     "Mela" = 1568924476;
    };
  };
} 
