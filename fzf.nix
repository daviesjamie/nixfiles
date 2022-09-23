{ ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--height 25%"
      "--min-height 15"
      "--reverse"
    ];
  };
}
