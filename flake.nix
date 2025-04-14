{
  description = "crdant's system configration ";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    sops-nix.url = "github:Mic92/sops-nix";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin/nix-darwin-24.11";
    darwin.inputs.nixpkgs.follows = "nixpkgs"; # ...

    _1password-shell-plugins.url = "github:1Password/shell-plugins";
    _1password-shell-plugins.inputs.nixpkgs.follows = "home-manager"; # ...

  };

  outputs = { self, nixpkgs, home-manager, darwin, ...}@inputs: 
    let
      inherit (self) outputs;
      system = builtins.currentSystem;
      isDarwin = nixpkgs.legacyPackages.${system}.stdenv.isDarwin;
    in {
      overlays = import ./overlays {inherit inputs;};

      nixosConfigurations = {
        mash = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {inherit inputs outputs;};
          modules = [ 
            ./hosts/mash/default.nix
            ./users/crdant/crdant.nix
          ];
        };
      };

      darwinConfigurations = {
        "grappa" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {inherit inputs outputs;};
          modules = [ 
            ./hosts/grappa/default.nix
            ./users/crdant/crdant.nix
            ./users/crdant/darwin.nix
          ];
        };

        "sochu" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {inherit inputs outputs;};
          modules = [ 
            ./hosts/sochu/default.nix
            ./users/crdant/chuck.nix
            ./users/crdant/darwin.nix
          ];
        };
      }; 

      homeConfigurations = {
        "chuck" = let 
            inherit system ;
            username = "chuck";
            homeDirectory = if isDarwin then 
                "/Users/chuck"
              else
                "/home/chuck";
            gitEmail = "chuck@replicated.com";
          in home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.${system};
            extraSpecialArgs = {inherit inputs outputs username homeDirectory gitEmail;};
            modules = [ 
              ./users/crdant/home.nix
            ];
          };

        "crdant" = let 
            inherit system ;
            username = "crdant";
            homeDirectory = if isDarwin then 
                "/Users/crdant"
              else
                "/home/crdant";
            gitEmail = "chuck@crdant.io";
          in home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.${system};
            extraSpecialArgs = {inherit inputs outputs username homeDirectory gitEmail;};
            modules = [ 
              ./users/crdant/home.nix
            ];
          };
        };
    };
}
