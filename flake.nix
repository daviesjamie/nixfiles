{
  description = "daviesjamie's Nix Configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    base16-shell.url = "github:base16-project/base16-shell";
    base16-shell.flake = false;

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    neovim.url = "github:daviesjamie/neovim-flake";
    neovim.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    darwin,
    nixpkgs,
    sops-nix,
    ...
  } @ inputs: let
    lib = import ./lib {inherit inputs;};
  in rec {
    inherit lib;

    darwinConfigurations = {
      makani = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/makani
        ];
      };
    };

    devShells = lib.forAllSystems (
      system: let
        pkgs = legacyPackages.${system};
      in {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            age
            inputs.neovim.packages.${system}.default
            sops
            ssh-to-age
          ];

          shellHook = ''
            export PATH="$PWD/bin:$PATH"
          '';
        };
      }
    );

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
      basil = lib.mkNixos {
        pkgs = legacyPackages.x86_64-linux;
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
