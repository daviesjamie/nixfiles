{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.nixfiles.paperless;
  backend = config.nixfiles.containers.backend;
  backendPkg =
    if backend == "docker"
    then pkgs.docker
    else pkgs.podman;
in {
  imports = [
    ./options.nix
    ./samba.nix
    ./user.nix
  ];

  config = lib.mkIf cfg.enable {
    nixfiles.containers.pods.paperless = {
      containers = {
        db = {
          image = "postgres:${cfg.postgresTag}";
          environment = {
            "POSTGRES_DB" = "paperless";
            "POSTGRES_USER" = "paperless";
            "POSTGRES_PASSWORD" = "paperless";
          };
          volumes = [
            {
              name = "pgdata";
              inner = "/var/lib/postgresql/data";
            }
          ];
        };

        redis = {
          image = "redis:${cfg.redisTag}";
          volumes = [
            {
              name = "redisdata";
              inner = "/data";
            }
          ];
        };

        web = {
          image = "ghcr.io/paperless-ngx/paperless-ngx:${cfg.imageTag}";
          dependsOn = [
            "paperless-db"
            "paperless-redis"
          ];
          ports = [
            {
              host = cfg.port;
              inner = 8000;
            }
          ];
          volumes = [
            {
              name = "data";
              inner = "/usr/src/paperless/data";
              user = "paperless";
              group = "paperless";
            }
            {
              name = "media";
              inner = "/usr/src/paperless/media";
              user = "paperless";
              group = "paperless";
            }
            {
              host = cfg.exportDir;
              inner = "/usr/src/paperless/export";
              user = "paperless";
              group = "paperless";
            }
            {
              host = cfg.consumeDir;
              inner = "/usr/src/paperless/consume";
              user = "paperless";
              group = "paperless";
            }
          ];
          environment = {
            "PAPERLESS_REDIS" =
              if backend == "docker"
              then "redis://paperless-redis:6379"
              else "redis://localhost:6379";
            "PAPERLESS_DBHOST" =
              if backend == "docker"
              then "paperless-db"
              else "localhost";
            "USERMAP_UID" = "${toString config.users.users.paperless.uid}";
            "USERMAP_GID" = "${toString config.users.groups.paperless.gid}";
          };
        };
      };
    };

    nixfiles.backups = let
      command = ''
        ${backendPkg}/bin/${backend} exec -i paperless-web document_exporter ../export
      '';
    in {
      backups = {
        paperless = {
          prepareCommand = "/run/wrappers/bin/sudo ${command}";
          paths = [cfg.exportDir];
        };
      };
      sudoRules = [{inherit command;}];
    };
  };
}
