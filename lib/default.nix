{ inputs, ... }:

rec {
  forAllSystems = inputs.nixpkgs.lib.genAttrs systems;

  mkHome = { pkgs, username, homeDirectory }: inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = {
      inherit homeDirectory inputs username;
    };
    modules = builtins.attrValues (import ../modules/home-manager) ++ [ ../home/${username} ];
  };

  systems = [
    "aarch64-darwin"
    "x86_64-linux"
  ];
}
