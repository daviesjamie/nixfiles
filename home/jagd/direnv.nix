{config, ...}: {
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
}
