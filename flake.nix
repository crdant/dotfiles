{
  description = "crdant's system configration ";


  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-23.11-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs"; # ...

    _1password-shell-plugins.url = "github:1Password/shell-plugins";
    _1password-shell-plugins.inputs.nixpkgs.follows = "home-manager"; # ...
  };

  outputs = { self, nixpkgs, home-manager, darwin, ...}@inputs: 
    let
      inherit (self) outputs;
    in {
      overlays = import ./overlays {inherit inputs;};

      darwinConfigurations = {
        "grappa" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {inherit inputs outputs;};
          modules = [ 
            ./hosts/grappa/default.nix
            ./users/crdant/crdant.nix
          ];
        };

        "sochu" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {inherit inputs outputs;};
          modules = [ 
            ./hosts/sochu/default.nix
            ./users/crdant/chuck.nix
          ];
        };
      }; 

      homeConfigurations = {
        "chuck" = let 
            system = "aarch64-darwin";
            username = "chuck";
            homeDirectory = "/Users/chuck";
          in home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.${system};
            extraSpecialArgs = {inherit inputs outputs username homeDirectory;};
            modules = [ 
              ./users/crdant/home-manager.nix
            ];
          };

        "crdant" = let 
            system = "aarch64-darwin";
            username = "crdant";
            homeDirectory = "/Users/crdant";
          in home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.${system};
            extraSpecialArgs = {inherit inputs outputs username homeDirectory;};
            modules = [ 
              ./users/crdant/home-manager.nix
            ];
          };
        };
    };
}
