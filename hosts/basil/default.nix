{
  config,
  inputs,
  pkgs,
  ...
}: let
  persistDir = config.nixfiles.eraseYourDarlings.persistDir;
in {
  imports = [
    ./hardware-configuration.nix
    ./nix.nix
    ./sops.nix
    ./users.nix
    ./zfs.nix
  ];

  networking.hostName = "basil";
  networking.hostId = "4e9cb0b8";

  system.stateVersion = "22.11";

  boot.supportedFilesystems = ["zfs"];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  i18n.defaultLocale = "en_GB.UTF-8";
  time.timeZone = "Europe/London";

  nixfiles.eraseYourDarlings.enable = true;

  environment.systemPackages = with pkgs; [
    git
    tree
    vim
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
    };
  };

  programs.zsh.enable = true;

  # Only keep the last 500MiB of systemd journal.
  services.journald.extraConfig = "SystemMaxUse=500M";

  nixfiles.containers.backend = "podman";
  nixfiles.containers.volumeBaseDir = "${persistDir}/docker-volumes";
  nixfiles.paperless.enable = true;
  nixfiles.paperless.consumeDir = "${persistDir}/paperless/consume";
  nixfiles.paperless.exportDir = "${persistDir}/paperless/export";
}
