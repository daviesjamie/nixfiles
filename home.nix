{ homeDirectory, pkgs, stateVersion, username }:

{
  home = { inherit homeDirectory stateVersion username; };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    fzf
    ghq
    hledger
    jq
    ripgrep
  ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
