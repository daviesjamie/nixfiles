{pkgs, ...}: {
  programs.tmux = {
    enable = true;

    baseIndex = 1;
    clock24 = true;
    escapeTime = 0;
    historyLimit = 50000;
    keyMode = "vi";
    mouse = true;
    prefix = "C-f";
    terminal = "screen-256color";

    extraConfig = ''
      # Add some vim-style bindings
      bind -r h select-pane -L
      bind -r j select-pane -D
      bind -r k select-pane -U
      bind -r l select-pane -R
      bind ^ last-window
      bind - last-window
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi V send-keys -X select-line
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel

      # Run tmux-sesh in a new window from anywhere with ctrl+g
      bind-key -n C-g new-window tmux-sesh

      # Make colors less garish
      colour_base="black"
      colour_dim_blue="#56949f"
      colour_bright_blue="#9ccfd8"
      set -g status-style "bg=$colour_base,fg=$colour_dim_blue"
      set -g window-status-current-style "bg=$colour_base,fg=$colour_bright_blue"

      # Give the left status section (session name) a bit more room
      set -g status-left-length 23

      # Make sure the right-most part of the session name is visible if it's
      # too long
      set -g status-left "[#{=-20:session_name}] "
    '';
  };

  home.packages = let
    tmuxsesh = pkgs.writeScriptBin "tmux-sesh" (builtins.readFile ./bin/tmux-sesh);
  in [tmuxsesh];
}
