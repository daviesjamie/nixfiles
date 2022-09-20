{ config, pkgs, ... }:

{
  home.username = "jagd";
  home.homeDirectory = "/Users/jagd";

  home.stateVersion = "22.05";

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
