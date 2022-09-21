{ homeDirectory, pkgs, stateVersion, username }:

{
  home = { inherit homeDirectory stateVersion username; };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
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

      directory = {
        style = "blue";
      };

      character = {
        success_symbol = "❯";
        error_symbol = "[❯](red)";
      };

      git_branch = {
        format = "[$branch]($style)";
      };

      cmd_duration = {
        format = "[$duration]($style)";
        style = "yellow";
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };
}
