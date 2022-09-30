{
  description = "daviesjamie's Nix Configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    base16-shell.url = "github:base16-project/base16-shell";
    base16-shell.flake = false;
  };

  outputs = {
    nixpkgs,
    ...
  } @ inputs: let
    lib = import ./lib {inherit inputs;};
  in rec {
    inherit lib;

    formatter = lib.forAllSystems (
      system:
        legacyPackages.${system}.alejandra
    );

    homeManagerModules = import ./modules/home-manager;

    legacyPackages = lib.forAllSystems (
      system:
        import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
    );

    nixosConfigurations = {
      basil = nixpkgs.lib.nixosSystem {
        pkgs = legacyPackages.x86_64-linux;
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/basil
        ];
      };
    };

    homeConfigurations = {
      "jagd@basil" = lib.mkHome {
        pkgs = legacyPackages.x86_64-linux;
        username = "jagd";
        homeDirectory = "/home/jagd";
      };

      "jagd@makani" = lib.mkHome {
        pkgs = legacyPackages.aarch64-darwin;
        username = "jagd";
        homeDirectory = "/Users/jagd";
      };
    };
  };
}
