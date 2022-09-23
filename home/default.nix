{ pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Enable `nix` command and flakes support
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  imports = [
    ./direnv.nix
    ./fzf.nix
    ./starship.nix
    ./zsh.nix
  ] ++ [
    ../modules/ghq.nix
  ];

  programs.ghq.enable = true;
  programs.ghq.enableZshIntegration = true;

  home.packages = with pkgs; [
    jq
    ripgrep
  ];
}
