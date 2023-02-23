{
  config,
  inputs,
  pkgs,
  ...
}: {
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
      passwordAuthentication = false;
      permitRootLogin = "no";
      kbdInteractiveAuthentication = false;
    };
  };

  # Only keep the last 500MiB of systemd journal.
  services.journald.extraConfig = "SystemMaxUse=500M";

  # Use docker for OCI containers
  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";

  # Do a `docker system prune -a` every week
  virtualisation.docker.autoPrune.enable = true;

  virtualisation.oci-containers.containers = {
    hello = {
      image = "nginxdemos/hello";
      ports = [ "8080:80" ];
    };
  };
}
