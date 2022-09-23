{
  description = "my nix system configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    base16-shell.url = "github:base16-project/base16-shell";
    base16-shell.flake = false;
  };

  outputs = inputs@{ nixpkgs, home-manager, base16-shell, ... }:
    let
      isDarwin = system: (builtins.elem system inputs.nixpkgs.lib.platforms.darwin);
      homePrefix = system: if isDarwin system then "/Users" else "/home";

      stateVersion = "22.05";
      system = "aarch64-darwin";
      username = "jagd";

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs pkgs; };

        modules = [
          ./home
          {
            home = {
              inherit stateVersion username;
              homeDirectory = "${homePrefix system}/${username}";
            };
          }
        ];
      };
    };
}
