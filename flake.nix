{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    base16-shell.url = "github:base16-project/base16-shell";
    base16-shell.flake = false;
  };

  outputs = { nixpkgs, home-manager, base16-shell, ... }:
    let
      stateVersion = "22.05";
      system = "aarch64-darwin";
      username = "jagd";
      homeDirectory = "/Users/jagd";

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          (import ./home.nix { inherit base16-shell homeDirectory pkgs stateVersion username; })
        ];
      };
    };
}
