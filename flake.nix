{
  description = "crdant's system configration ";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    sops-nix.url = "github:Mic92/sops-nix";

    # Kernel, firmware, and graphics support for NixOS on Apple Silicon;
    # keeps its own nixpkgs pin so the patched kernel stays as tested
    nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    darwin.inputs.nixpkgs.follows = "nixpkgs"; # ...

    _1password-shell-plugins.url = "github:1Password/shell-plugins";
    _1password-shell-plugins.inputs.nixpkgs.follows = "home-manager"; # ...

    # Upstream flake for the Hermes agent; keeps its own nixpkgs so builds
    # match what its CI tests
    hermes-agent.url = "github:NousResearch/hermes-agent";

  };

  outputs = { self, nixpkgs, home-manager, darwin, ...}@inputs:
    let
      inherit (self) outputs;

      supportedSystems = [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" ];

      mkPkgs = system: import nixpkgs {
        inherit system;
        overlays = [
        ];
      };

      # Helper function to create home configurations with profiles
      mkHomeConfig = { system, username, gitEmail, profile ? "full"
        , homeDirectory ? (if (mkPkgs system).stdenv.isDarwin then "/Users/${username}" else "/home/${username}")
        , homeModule ? (./. + "/home/users/${username}/home.nix")
      }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          extraSpecialArgs = {inherit inputs outputs username homeDirectory gitEmail profile;};
          modules = [
            homeModule
          ];
        };
    in {
      overlays = import ./overlays {inherit inputs;};

      # Custom packages, exposed so they can be built and updated on their own.
      # Each system only gets the packages whose meta.platforms include it.
      packages = nixpkgs.lib.genAttrs supportedSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ outputs.overlays.unstable-packages ];
          };
        in
          nixpkgs.lib.filterAttrs
            (_: pkg: nixpkgs.lib.meta.availableOn pkgs.stdenv.hostPlatform pkg)
            (import ./pkgs { inherit pkgs; }));

      devShells = nixpkgs.lib.genAttrs supportedSystems (system:
        let pkgs = mkPkgs system; in {
          default = pkgs.mkShellNoCC {
            packages = [
              pkgs.gnumake
              pkgs.jq
              pkgs.sops
              pkgs.gnupg
              pkgs.shellcheck
              (pkgs.python3.withPackages (ps: [ ps.requests ]))
              home-manager.packages.${system}.home-manager
            ];
            # Legacy package tests import <nixpkgs>; use the same locked input.
            NIX_PATH = "nixpkgs=${pkgs.path}";
          };
        });

      nixosConfigurations = {
        mash = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {inherit inputs outputs;};
          modules = [
            inputs.sops-nix.nixosModules.sops
            ./systems/hosts/mash/default.nix
            ./home/users/crdant/crdant.nix
          ];
        };
        sochu = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {inherit inputs outputs;};
          modules = [ 
            ./systems/hosts/sochu/default.nix
            ./systems/hosts/sochu/nixos.nix
            ./home/users/crdant/crdant.nix
          ];
        };
      };


      darwinConfigurations = {
        "aguardiente" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {inherit inputs outputs;};
          modules = [ 
            ./systems/hosts/aguardiente/default.nix
            ./home/users/crdant/crdant.nix
            ./home/users/crdant/darwin.nix
          ];
        };

        "grappa" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {inherit inputs outputs;};
          modules = [ 
            ./systems/hosts/grappa/default.nix
            ./home/users/crdant/crdant.nix
            ./home/users/crdant/darwin.nix
          ];
        };

        "cachaca" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {inherit inputs outputs;};
          modules = [ 
            ./systems/hosts/cachaca/default.nix
            ./home/users/crdant/crdant.nix
            ./home/users/crdant/darwin.nix
          ];
        };

        "sochu" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {inherit inputs outputs;};
          modules = [
            ./systems/hosts/sochu/default.nix
            ./systems/hosts/sochu/darwin.nix
            ./home/users/crdant/crdant.nix
            ./home/users/crdant/darwin.nix
          ];
        };
        "pisco" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {inherit inputs outputs;};
          modules = [
            ./systems/hosts/pisco/default.nix
            ./home/users/crdant/crdant.nix
            ./home/users/crdant/darwin.nix
            ./home/users/luca/luca.nix
            ./home/users/dewey/dewey.nix
          ];
        };
      }; 

      homeConfigurations =
        let
          # User configurations with different profiles
          userConfigs = {
            crdant = {
              gitEmail = "crdant@shortrib.io";
            };
            luca = {
              gitEmail = "";
            };
            dewey = {
              gitEmail = "";
            };
          };

          # Available profiles
          profiles = [ "full" "development" "minimal" "server" ];

          # Generate configurations for each user-profile-system combination
          # Names: "user@system", "user:profile@system"
          generateConfigs = userConfigs: profiles:
            builtins.listToAttrs (
              builtins.concatLists (
                builtins.map (system:
                  builtins.concatLists (
                    builtins.map (username:
                      let userConfig = userConfigs.${username}; in
                      builtins.map (profile: {
                        name =
                          let base = if profile == "full" then username else "${username}:${profile}";
                          in "${base}@${system}";
                        value = mkHomeConfig ({ inherit system username profile; } // userConfig);
                      }) profiles
                    ) (builtins.attrNames userConfigs)
                  )
                ) supportedSystems
              )
            );
        in
        generateConfigs userConfigs profiles;
    };
}
