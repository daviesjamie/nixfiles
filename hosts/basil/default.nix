{
  config,
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

  networking.firewall.allowedTCPPorts = [80];

  # Only keep the last 500MiB of systemd journal.
  services.journald.extraConfig = "SystemMaxUse=500M";

  nixfiles.containers.backend = "podman";
  nixfiles.containers.volumeBaseDir = "${persistDir}/docker-volumes";

  nixfiles.paperless.enable = true;
  nixfiles.paperless.enableSamba = true;
  nixfiles.paperless.consumeDir = "${persistDir}/paperless/consume";
  nixfiles.paperless.exportDir = "${persistDir}/paperless/export";

  nixfiles.backups.enable = true;

  sops.secrets."backups/bucket/accessKey" = {};
  sops.secrets."backups/bucket/secretKey" = {};
  sops.secrets."backups/repo/location" = {};
  sops.secrets."backups/repo/password" = {};

  sops.templates."backups.env".content = ''
    AWS_ACCESS_KEY_ID="${config.sops.placeholder."backups/bucket/accessKey"}"
    AWS_SECRET_ACCESS_KEY="${config.sops.placeholder."backups/bucket/secretKey"}"
  '';

  nixfiles.backups.environmentFile = config.sops.templates."backups.env".path;
  nixfiles.backups.repoLocationFile = config.sops.secrets."backups/repo/location".path;
  nixfiles.backups.repoPasswordFile = config.sops.secrets."backups/repo/password".path;

  services.caddy.enable = true;
  services.caddy.virtualHosts."paperless.jagd.me:80".extraConfig = ''
    encode gzip
    reverse_proxy http://localhost:${toString config.nixfiles.paperless.port}
  '';
}
