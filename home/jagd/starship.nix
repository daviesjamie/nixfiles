{pkgs, ...}: {
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
        format = "[$user]($style)";
        style_root = "red";
        style_user = "blue";
      };

      hostname = {
        format = "[@$hostname]($style)";
        style = "purple";
        ssh_symbol = "";
      };

      directory = {
        format = " [$path]($style)[$read_only]($read_only_style) ";
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
}
