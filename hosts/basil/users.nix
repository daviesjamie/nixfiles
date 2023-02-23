{
  config,
  pkgs,
  ...
}: {
  users.mutableUsers = false;

  users.users.jagd = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBJLkRU/0rnP7dYbZ/jRrl94vaDJvTi/JbwkZLDPIQOD"
    ];
    passwordFile = config.sops.secrets."users/jagd/password".path;
  };

  sops.secrets."users/jagd/password" = {
    neededForUsers = true;
  };

  security.sudo.wheelNeedsPassword = false;
}
