{
  description = "daviesjamie's Nix Configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    base16-shell.url = "github:base16-project/base16-shell";
    base16-shell.flake = false;
  };

  outputs = { nixpkgs, home-manager, base16-shell, ... }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
      ];

    in rec {
      homeManagerModules = import ./modules/home-manager;

      legacyPackages = forAllSystems (system:
        import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
      );

      nixosConfigurations = {
        basil = nixpkgs.lib.nixosSystem {
          pkgs = legacyPackages.x86_64-linux;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/basil
          ];
        };
      };

      homeConfigurations = {
        "jagd@basil" = home-manager.lib.homeManagerConfiguration {
          pkgs = legacyPackages.x86_64-linux;
          extraSpecialArgs = {
            inherit inputs;
            username = "jagd";
            homeDirectory = "/home/jagd";
          };
          modules = (builtins.attrValues homeManagerModules) ++ [
            ./home/jagd
          ];
        };

        "jagd@makani" = home-manager.lib.homeManagerConfiguration {
          pkgs = legacyPackages.aarch64-darwin;
          extraSpecialArgs = {
            inherit inputs;
            username = "jagd";
            homeDirectory = "/Users/jagd";
          };
          modules = (builtins.attrValues homeManagerModules) ++ [
            ./home/jagd
          ];
        };
      };
    };
}
