{ config, inputs, ... }:

let
  base16 = {
    defaultTheme = "tomorrow-night";
    path = inputs.base16-shell.outPath;
  };

  historyFile = "${config.home.homeDirectory}/.zsh_history";
in {
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    history = {
      extended = true;     # Save start/end timestamps for each command
      ignoreDups = true;   # Remove older duplicates when new lines are added
      ignoreSpace = true;  # Don't keep any lines starting with whitespace
      path = historyFile;
      save = 10000;        # Number of lines to write to history file
      size = 10000;        # Number of lines to keep in session
    };

    envExtra = ''
      export EDITOR=vim
      export VISUAL=$EDITOR
    '';

    initExtra = ''
      ########################################################################
      # HISTORY
      ########################################################################

      # Remove unnecessary whitespace from commands when saving to history
      setopt HIST_REDUCE_BLANKS

      # When using history substitution (such as sudo !!), don't execute line
      # directly - instead load it into prompt for editing
      setopt HIST_VERIFY

      ########################################################################
      # COMPLETION
      ########################################################################

      unsetopt MENU_COMPLETE   # don't autoselect the first completion entry
      setopt ALWAYS_TO_END     # always move cursor to end of word after completion
      setopt AUTO_MENU         # show completion menu on succesive tab press
      setopt COMPLETE_IN_WORD  # allow completing in the middle of words

      # Enable menu selection
      zstyle ':completion:*:*:*:*:*' menu select

      # Try completing, in order:
      # - case-insensitive matches
      # - partial-word matches
      # - substring matches
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
    '';
  };
}
