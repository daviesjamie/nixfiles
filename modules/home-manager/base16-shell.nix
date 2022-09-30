{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.base16;
  base16Path = inputs.base16-shell.outPath;
in {
  options.programs.base16 = {
    defaultTheme = lib.mkOption {
      type = types.str;
      default = "tomorrow-night";
      example = ''programs.base16.defaultTheme = "tomorrow-night"'';
      description = "The default theme to load if the user hasn't chosen one";
    };

    enableZshIntegration = lib.mkEnableOption "Whether to enable base16-shell integration with zsh";
  };

  config = {
    programs.zsh.initExtra = mkIf cfg.enableZshIntegration ''
      BASE16_THEME_DEFAULT="${cfg.defaultTheme}"
      [ -n "$PS1" ] && \
        [ -s "${base16Path}/profile_helper.sh" ] && \
          source "${base16Path}/profile_helper.sh"
    '';
  };
}
