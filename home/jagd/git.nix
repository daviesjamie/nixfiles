{...}: {
  programs.git = {
    enable = true;

    userName = "Jamie Davies";
    userEmail = "jamie@jagd.me";

    extraConfig = {
      core.editor = "vim";
      fetch.prune = true;
      init.defaultBranch = "main";
      push.default = "current";
      pager.log = "less --quit-if-one-screen --no-init --RAW-CONTROL-CHARS --chop-long-lines";
    };

    aliases = {
      aa = "add --all";
      amend = "commit --amend";
      c = "commit";
      co = "checkout";
      di = "diff";
      dc = "diff --cached";
      ds = "diff --stat";
      st = "status";
      uns = "restore --staged";

      # Pretty one-line logs:
      #   l  = all commits, only current branch
      #   la = all commits, all reachable refs
      #   r  = recent commits, only current branch
      #   ra = recent commits, all reachable refs
      l = "log --pretty='format:%C(yellow)%h%C(red)%d %C(reset)%s %C(green)%an%C(reset), %C(cyan)%ar'";
      la = "!git l --all";
      r = "!git l -20";
      ra = "!git r --all";
    };

    ignores = [
      # OS-generated files
      ".DS_Store"
      "._*"
      ".Spotlight-V100"
      ".Trashes"
      "Thumbs.db"

      # Vim-generated files
      "*.swp"
      "*~"

      # Logs and databases
      "*.log"
      "*.sqlite"
    ];
  };
}
