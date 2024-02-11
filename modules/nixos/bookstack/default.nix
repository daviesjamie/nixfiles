{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.nixfiles.bookstack;
  backend = config.nixfiles.containers.backend;
  backendPkg =
    if backend == "docker"
    then pkgs.docker
    else pkgs.podman;
in {
  imports = [
    ./options.nix
  ];

  config = lib.mkIf cfg.enable {
    nixfiles.containers.pods.bookstack = {
      containers = {
        db = {
          image = "mariadb:${cfg.mariadbTag}";
          environment = {
            "MYSQL_DATABASE" = "bookstack";
            "MYSQL_USER" = "bookstack";
            "MYSQL_PASSWORD" = "bookstack";
            "MYSQL_RANDOM_ROOT_PASSWORD" = "yes";
            "TZ" = "Europe/London";
          };
          volumes = [
            {
              name = "mysqldata";
              inner = "/var/lib/mysql";
            }
          ];
        };

        web = {
          image = "lscr.io/linuxserver/bookstack:${cfg.imageTag}";
          dependsOn = [
            "bookstack-db"
          ];
          ports = [
            {
              host = cfg.port;
              inner = 80;
            }
          ];
          environment = {
            "APP_URL" = cfg.appUrl;
            "DB_HOST" = "bookstack-db";
            "DB_USER" = "bookstack";
            "DB_PASS" = "bookstack";
            "DB_DATABASE" = "bookstack";
          };
          volumes = [
            {
              name = "data";
              inner = "/config";
            }
          ];
        };
      };
    };

    nixfiles.backups = let
      command = ''
        ${backendPkg}/bin/${backend} exec -i bookstack-db mysqldump -u bookstack -p bookstack --databases bookstack > mysqldump.sql
      '';
    in {
      backups = {
        bookstack = {
          prepareCommand = "/run/wrappers/bin/sudo ${command}";
          paths = let
            volumeBaseDir = config.nixfiles.containers.volumeBaseDir;
          in [
            "mysqldump.sql"
            "${volumeBaseDir}/bookstack/data"
          ];
        };
      };
      sudoRules = [{inherit command;}];
    };
  };
}
