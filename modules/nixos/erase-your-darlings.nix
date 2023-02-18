{
  config,
  lib,
  ...
}: let
  cfg = config.nixfiles.eraseYourDarlings;
in {
  # For the idea behind this module, see
  # https://grahamc.com/blog/erase-your-darlings

  options.nixfiles.eraseYourDarlings = {
    enable = lib.mkEnableOption "Whether to enable wiping / on boot";

    rootSnapshot = lib.mkOption {
      type = lib.types.str;
      default = "local/volatile/root@blank";
      description = "The (blank) root snapshot to restore on boot";
      example = ''nixfiles.eraseYourDarlings.rootSnapshot = "local/volatile/root@blank"'';
    };

    persistDir = lib.mkOption {
      type = lib.types.path;
      default = "/persist";
      description = "Path to the persistent storage";
      example = ''nixfiles.eraseYourDarlings.persistDir = "/persist"'';
    };
  };

  config = lib.mkIf cfg.enable {
    # Wipe / on boot
    boot.initrd.postDeviceCommands = lib.mkAfter ''
      zfs rollback -r ${cfg.rootSnapshot}
    '';

    # Persist /etc/machine-id so that journalctl can access logs from previous boots
    environment.etc.machine-id = {
      source = "${toString cfg.persistDir}/etc/machine-id";
      mode = "0444";
    };

    # Set SSH host keys to versions in persistent storage
    services.openssh.hostKeys = [
      {
        path = "${toString cfg.persistDir}/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "${toString cfg.persistDir}/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];

    # Persist /etc/nixos config
    systemd.tmpfiles.rules = [
      "L+ /etc/nixos - - - - ${toString cfg.persistDir}/etc/nixos"
    ];
  };
}
