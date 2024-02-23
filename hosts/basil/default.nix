{
  config,
  pkgs,
  ...
}: let
  persistDir = config.nixfiles.eraseYourDarlings.persistDir;
in {
  imports = [
    ./backups.nix
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

  networking.firewall.allowedTCPPorts = [53 80];
  networking.firewall.allowedUDPPorts = [53];

  # Containers
  nixfiles.containers.backend = "podman";
  nixfiles.containers.volumeBaseDir = "${persistDir}/docker-volumes";

  # Paperless
  nixfiles.paperless.enable = true;
  nixfiles.paperless.enableSamba = true;
  nixfiles.paperless.consumeDir = "${persistDir}/paperless/consume";
  nixfiles.paperless.exportDir = "${persistDir}/paperless/export";

  # AdGuard Home
  nixfiles.adguardhome.enable = true;
  nixfiles.adguardhome.port = 8001;

  # Caddy reverse proxy
  services.caddy.enable = true;
  services.caddy.email = "letsencrypt@jagd.me";
  services.caddy.package = pkgs.callPackage ../../pkgs/caddy {
    plugins = ["github.com/caddy-dns/digitalocean"];
  };

  services.caddy.virtualHosts = let
    tlsConfig = ''
      tls {
        dns digitalocean {env.DIGITALOCEAN_API_KEY}
      }
    '';
  in {
    "dns.jagd.me".extraConfig = ''
      reverse_proxy :${toString config.nixfiles.adguardhome.port}
      ${tlsConfig}
    '';
    "paperless.jagd.me".extraConfig = ''
      encode gzip
      reverse_proxy :${toString config.nixfiles.paperless.port}
      ${tlsConfig}
    '';
  };

  sops.secrets."dns/digitalocean/apiKey" = {};

  sops.templates."caddy.env".content = ''
    DIGITALOCEAN_API_KEY="${config.sops.placeholder."dns/digitalocean/apiKey"}"
  '';

  systemd.services.caddy = {
    serviceConfig = {
      # Required to use ports < 1024
      AmbientCapabilities = "cap_net_bind_service";
      CapabilityBoundingSet = "cap_net_bind_service";

      EnvironmentFile = config.sops.templates."caddy.env".path;
    };
  };
}
