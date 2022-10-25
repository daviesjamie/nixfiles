{ pkgs, ... }:
{
  environment = {
    loginShell = pkgs.zsh;
  };

  services.nix-daemon.enable = true;

  system.defaults = {
    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
    };
  };
}
