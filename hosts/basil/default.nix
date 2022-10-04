{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./sops.nix
  ];

  networking.hostName = "basil";

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  i18n.defaultLocale = "en_GB.UTF-8";
  time.timeZone = "Europe/London";

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

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

  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
    permitRootLogin = "no";
  };

  system.stateVersion = "22.05";
}
