{ base16-shell, config, homeDirectory, pkgs, stateVersion, username }:

{
  home = { inherit homeDirectory stateVersion username; };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    ghq
    jq
    ripgrep
  ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    stdlib = ''
      # Store .direnv in cache instead of project dir
      declare -A direnv_layout_dirs
      direnv_layout_dir() {
        echo "''${direnv_layout_dirs[$PWD]:=$(
          echo -n "${config.xdg.cacheHome}/direnv/layouts/"
          echo -n "$PWD" | shasum | cut -d ' ' -f 1
        )}"
      }
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--height 25%"
      "--min-height 15"
      "--reverse"
    ];
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = pkgs.lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_state"
        "$git_status"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];

      username = {
        format = "[$user]($style) ";
        style_root = "red";
        style_user = "blue";
      };

      hostname = {
        style = "magenta";
        ssh_symbol = "";
      };

      directory = {
        style = "cyan";
        truncate_to_repo = false;
        truncation_length = 8;
        truncation_symbol = "…/";
      };

      git_branch = {
        format = "[$branch]($style)";
        style = "bright-black";
      };

      git_state = {
		format = "([$state( $progress_current/$progress_total)]($style))";
		style = "bright-black";
      };

      git_status = {
        format = "([$modified$staged$untracked$conflicted]($style))";
        style = "bright-black";
        conflicted = "!";
        modified = "*";
        staged = "+";
        untracked = "?";
      };

      cmd_duration = {
        format = " [$duration]($style)";
        style = "yellow";
        min_time = 5000;
      };

      character = {
        success_symbol = "❯";
        error_symbol = "[❯](red)";
      };
    };
  };

  programs.zsh = let
    default_theme = "tomorrow-night";
  in {
    enable = true;
    enableCompletion = true;

    envExtra = ''
      export GHQ_ROOT="$HOME/src"
    '';

    initExtra = ''
      BASE16_THEME_DEFAULT="${default_theme}"
      [ -n "$PS1" ] && \
        [ -s "${base16-shell.outPath}/profile_helper.sh" ] && \
          source "${base16-shell.outPath}/profile_helper.sh"

      gcd() {
        local repo
        local repo_path
        repo=$(ghq list | fzf) &&
          repo_path=$(ghq list -p -e "$repo") &&
          cd "$repo_path"
      }
    '';
  };
}
