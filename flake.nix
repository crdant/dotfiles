{
  description = "crdant's system confugration ";


  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-23.11-darwin";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs"; # ...
  };

  outputs = { self, nixpkgs, home-manager, darwin, ...}@inputs: let 
      mkSystem = import ./lib/mksystem.nix {
        inherit nixpkgs inputs ;
      };
    in {
      darwinConfigurations."grappa" = mkSystem "grappa"  {
        system = "aarch64-darwin";
        username = "crdant" ;
        darwin = true ;
      };

      darwinConfigurations."sochu" = mkSystem "sochu"  {
        system = "aarch64-darwin";
        username = "chuck" ;
        darwin = true ;
      };
    };
}
