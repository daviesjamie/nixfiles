{
  config,
  lib,
  ...
}: let
  cfg = config.nixfiles.backups;

  mkSudoRule = rule: {
    users = [config.users.users.backups.name];
    runAs = rule.runAs;
    commands = [
      {
        command = rule.command;
        options = ["NOPASSWD"];
      }
    ];
  };

  mkBackup = name: options:
    lib.nameValuePair name {
      backupCleanupCommand = options.cleanupCommand;
      backupPrepareCommand = options.prepareCommand;
      environmentFile = cfg.environmentFile;
      passwordFile = cfg.repoPasswordFile;
      paths = options.paths;
      pruneOpts = [
        "--keep-daily ${toString options.retention.daily}"
        "--keep-weekly ${toString options.retention.weekly}"
        "--keep-monthly ${toString options.retention.monthly}"
        "--keep-yearly ${toString options.retention.yearly}"
      ];
      repositoryFile = cfg.repoLocationFile;
      timerConfig = {
        OnCalendar = options.startAt;
        Persistent = true;
        RandomizedDelaySec = options.startAtRandomDelay;
      };
      user = config.users.users.backups.name;
    };
in {
  imports = [
    ./options.nix
  ];

  config = lib.mkIf cfg.enable {
    users.users.backups = {
      description = "Backup service user";
      isSystemUser = true;
      group = "nogroup";
    };

    security.sudo.extraRules = map mkSudoRule cfg.sudoRules;

    services.restic.backups = lib.mapAttrs' mkBackup cfg.backups;
  };
}
