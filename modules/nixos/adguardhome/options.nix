{lib, ...}: {
  options.nixfiles.adguardhome = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the AdGuard Home service.";
    };

    exposeWizard = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether the port for this container should route to the regular web interface or the initial set-up wizard.";
    };

    imageTag = lib.mkOption {
      type = lib.types.str;
      default = "latest";
      description = "The tag to use for the `adguard/adguardhome` container image.";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 8000;
      description = "The port (on 127.0.0.1) to expose the AdGuard Home web interface on.";
    };
  };
}
