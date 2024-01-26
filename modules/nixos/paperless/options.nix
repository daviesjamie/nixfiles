{lib, ...}: {
  options.nixfiles.paperless = {
    consumeDir = lib.mkOption {
      type = lib.types.path;
      description = "The path that the Paperless service will consume documents from.";
    };

    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Paperless service.";
    };

    exportDir = lib.mkOption {
      type = lib.types.path;
      description = "The path that the Paperless document exporter will export data to.";
    };

    imageTag = lib.mkOption {
      type = lib.types.str;
      default = "latest";
      description = "The tag to use for the `ghcr.io/paperless-ngx/paperless-ngx` container image.";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 8000;
      description = "The port (on 127.0.0.1) to expose the paperless web interface on.";
    };

    postgresTag = lib.mkOption {
      type = lib.types.str;
      default = "16";
      description = "The tag to use for the `postgres` container image.";
    };

    redisTag = lib.mkOption {
      type = lib.types.str;
      default = "7";
      description = "The tag to use for the `redis` container image.";
    };
  };
}
