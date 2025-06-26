{
  description = "crdant's system configration ";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-25.05-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    sops-nix.url = "github:Mic92/sops-nix";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin/nix-darwin-25.05";
    darwin.inputs.nixpkgs.follows = "nixpkgs"; # ...

    _1password-shell-plugins.url = "github:1Password/shell-plugins";
    _1password-shell-plugins.inputs.nixpkgs.follows = "home-manager"; # ...

  };

  outputs = { self, nixpkgs, home-manager, darwin, ...}@inputs: 
    let
      inherit (self) outputs;
      system = builtins.currentSystem;
      isDarwin = nixpkgs.legacyPackages.${system}.stdenv.isDarwin;
      
      # Helper function to create home configurations with profiles
      mkHomeConfig = { username, homeDirectory, gitEmail, profile ? "full" }: 
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = {inherit inputs outputs username homeDirectory gitEmail profile;};
          modules = [ 
            ./home/users/crdant/home.nix
          ];
        };
    in {
      overlays = import ./overlays {inherit inputs;};

      nixosConfigurations = {
        mash = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {inherit inputs outputs;};
          modules = [ 
            ./systems/hosts/mash/default.nix
            ./home/users/crdant/crdant.nix
          ];
        };
      };

      darwinConfigurations = {
        "grappa" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {inherit inputs outputs;};
          modules = [ 
            ./systems/hosts/grappa/default.nix
            ./home/users/crdant/crdant.nix
            ./home/users/crdant/darwin.nix
          ];
        };

        "sochu" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {inherit inputs outputs;};
          modules = [ 
            ./systems/hosts/sochu/default.nix
            ./home/users/crdant/chuck.nix
            ./home/users/crdant/darwin.nix
          ];
        };
      }; 

      homeConfigurations = 
        let
          # User configurations with different profiles
          userConfigs = {
            chuck = {
              homeDirectory = if isDarwin then "/Users/chuck" else "/home/chuck";
              gitEmail = "chuck@replicated.com";
            };
            crdant = {
              homeDirectory = if isDarwin then "/Users/crdant" else "/home/crdant";
              gitEmail = "chuck@crdant.io";
            };
          };
          
          # Available profiles
          profiles = [ "full" "development" "minimal" "server" ];
          
          # Generate configurations for each user-profile combination
          generateConfigs = userConfigs: profiles:
            builtins.listToAttrs (
              builtins.concatLists (
                builtins.map (username: 
                  let userConfig = userConfigs.${username}; in
                  builtins.map (profile: {
                    name = if profile == "full" then username else "${username}:${profile}";
                    value = mkHomeConfig {
                      inherit username profile;
                      inherit (userConfig) homeDirectory gitEmail;
                    };
                  }) profiles
                ) (builtins.attrNames userConfigs)
              )
            );
        in
        generateConfigs userConfigs profiles;
    };
}
