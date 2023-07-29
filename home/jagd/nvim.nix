{inputs, ...}: {
  imports = [
    inputs.neovim.homeManagerModules.default
  ];

  programs.nvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };
}
