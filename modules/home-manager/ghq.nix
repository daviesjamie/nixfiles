{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.ghq;
  package = pkgs.ghq;
  ghqRoot = "${config.home.homeDirectory}/src";
  gcd = ''
    gcd() {
      local repo
      local repo_path

      if [[ $# -gt 0 ]]; then
        repo=$(ghq list | fzf -1 -q "$*")
      else
        repo=$(ghq list | fzf)
      fi

      [ $? -eq 0 ] && repo_path=$(ghq list -p -e $repo) && cd $repo_path
    }
  '';
in {
  options.programs.ghq = {
    enable = lib.mkEnableOption "Whether to enable the ghq repository clone manager";
    enableBashIntegration = lib.mkEnableOption "Whether to add the gcd function to bash";
    enableZshIntegration = lib.mkEnableOption "Whether to add the gcd function to zsh";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [package];

    programs.bash.initExtra = lib.mkIf cfg.enableBashIntegration ''
      export GHQ_ROOT='${ghqRoot}'";
      ${gcd}
    '';

    programs.zsh.envExtra = lib.mkIf cfg.enableZshIntegration "export GHQ_ROOT='${ghqRoot}'";
    programs.zsh.initExtra = lib.mkIf cfg.enableZshIntegration "${gcd}";
  };
}
