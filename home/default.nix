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
    ./git.nix
    ./starship.nix
    ./zsh.nix
  ] ++ [
    ../modules/base16-shell.nix
    ../modules/ghq.nix
  ];

  programs.base16.defaultTheme = "tomorrow-night";
  programs.base16.enableZshIntegration = true;

  programs.ghq.enable = true;
  programs.ghq.enableZshIntegration = true;

  home.packages = with pkgs; [
    jq
    ripgrep
  ];
}
