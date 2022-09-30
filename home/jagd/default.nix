{
  homeDirectory,
  pkgs,
  username,
  ...
}: {
  imports = [
    ./direnv.nix
    ./fzf.nix
    ./git.nix
    ./starship.nix
    ./zsh.nix
  ];

  home = {
    inherit homeDirectory username;
    stateVersion = "22.05";
  };

  # Enable `nix` command and flakes support
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.base16.defaultTheme = "tomorrow-night";
  programs.base16.enableZshIntegration = true;

  programs.ghq.enable = true;
  programs.ghq.enableZshIntegration = true;

  home.packages = with pkgs; [
    jq
    ripgrep
  ];
}
