{
  config,
  lib,
  ...
}: let
  cfg = config.nixfiles.paperless;
  backend = config.nixfiles.containers.backend;
in {
  imports = [
    ./options.nix
    ./sftp.nix
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
            }
            {
              name = "media";
              inner = "/usr/src/paperless/media";
            }
            {
              host = cfg.exportDir;
              inner = "/usr/src/paperless/export";
            }
            {
              host = cfg.consumeDir;
              inner = "/usr/src/paperless/consume";
              user = "root";
              group = "paperless";
              mode = "0775";
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
  };
}
