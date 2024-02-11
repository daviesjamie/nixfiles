{lib, ...}: {
  options.nixfiles.bookstack = {
    appUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "The URL that the Bookstack service should be accessible at.";
    };

    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Bookstack service.";
    };

    imageTag = lib.mkOption {
      type = lib.types.str;
      default = "latest";
      description = "The tag to use for the `lscr.io/linuxserver/bookstack` container image.";
    };

    mariadbTag = lib.mkOption {
      type = lib.types.str;
      default = "11";
      description = "The tag to use for the `mariadb` container image.";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 8000;
      description = "The port (on 127.0.0.1) to expose the Bookstack web interface on.";
    };
  };
}
