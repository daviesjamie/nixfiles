{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./sops.nix
  ];

  networking.hostName = "basil";
  networking.hostId = "4e9cb0b8";

  boot.supportedFilesystems = ["zfs"];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  i18n.defaultLocale = "en_GB.UTF-8";
  time.timeZone = "Europe/London";

  nixfiles.eraseYourDarlings.enable = true;

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    # Pin nixpkgs to the same version that built the system
    registry.nixpkgs.flake = inputs.nixpkgs;
  };

  users.mutableUsers = false;
  security.sudo.wheelNeedsPassword = false;
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
    settings = {
      passwordAuthentication = false;
      permitRootLogin = "no";
      kbdInteractiveAuthentication = false;
    };
  };

  system.stateVersion = "22.11";
}
