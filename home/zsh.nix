{ inputs, ... }:

{
  programs.zsh = let
    defaultTheme = "tomorrow-night";
  in {
    enable = true;
    enableCompletion = true;

    initExtra = let
      base16Path = inputs.base16-shell.outPath;
    in ''
      BASE16_THEME_DEFAULT="${defaultTheme}"
      [ -n "$PS1" ] && \
        [ -s "${base16Path}/profile_helper.sh" ] && \
          source "${base16Path}/profile_helper.sh"
    '';
  };
}
