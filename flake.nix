{
  description = "crdant's system configration ";


  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-23.11-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs"; # ...
  };

  outputs = { self, nixpkgs, home-manager, darwin, ...}@inputs: 
    let
      inherit (self) outputs;
    in {
      overlays = import ./overlays {inherit inputs;};

      darwinConfigurations."grappa" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {inherit inputs outputs;};
        modules = [ 
          ./hosts/grappa/default.nix
          ./users/crdant/chuck.nix
          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.crdant = import ./users/crdant/home-manager.nix;
          }
        ];
      };

      darwinConfigurations."sochu" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {inherit inputs outputs;};
        modules = [ 
          ./hosts/sochu/default.nix
          ./users/crdant/chuck.nix
          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.chuck = import ./users/crdant/home-manager.nix;
          }
        ];
      };
    };
}
