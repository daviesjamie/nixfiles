{
  inputs,
  pkgs,
  ...
}: {
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    # Pin nixpkgs to the same version that built the system
    registry.nixpkgs.flake = inputs.nixpkgs;

    # Collect nix store garbage and optimise daily.
    gc.automatic = true;
    gc.options = "--delete-older-than 30d";
    optimise.automatic = true;

    # Disable sandbox so that `xcaddy` build tool can access the internet
    settings.sandbox = false;
  };
}
