{
  description = "crdant's system confugration ";


  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-22.11-darwin";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs"; # ...
  };

  outputs = { self, nixpkgs, home-manager, darwin }: {

    darwinConfigurations."grappa" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";

      modules = [ 
        ./hosts/grappa/default.nix
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.crdant = import ./users/crdant/home-manager.nix;
        }
      ];
    };
  };
}
