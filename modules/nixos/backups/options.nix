{lib, ...}: let
  backupOptions = {
    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "The list of paths to back up";
    };

    prepareCommand = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "A script that must run before starting the backup process";
    };

    cleanupCommand = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "A script that must run after finishing the backup process";
    };

    startAt = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      description = "When to run the backup. See `systemd.time` for format.";
    };

    startAtRandomDelay = lib.mkOption {
      type = lib.types.str;
      default = "0";
      description = "Delay starting the backup by a randomly selected amount of time between 0 and the specified value.";
    };
  };

  sudoRuleOptions = {
    command = lib.mkOption {
      type = lib.types.str;
      description = "The command for which the rule applies.";
    };

    runAs = lib.mkOption {
      type = lib.types.str;
      default = "ALL:ALL";
      description = ''
        The user / group under which the command is allowed to run.

        A user can be specified using just the username: `"foo"`. It is also
        possible to specify a user/group combination using `"foo:bar"` or to
        only allow running as a specific group with `":bar"`.
      '';
    };
  };
in {
  options.nixfiles.backups = {
    backups = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {options = backupOptions;});
      default = {};
      description = "Attrset of backup job definitions.";
      example = ''
        nixfiles.backups.backups = {
          myService = {
            prepareCommand = "/run/wrappers/bin/sudo myService --backup";
            paths = [ "/persist/myService/backup" ];
            runAt = "05:00";
            startAtRandomDelay = "0";
          };
        };
      '';
    };

    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the backup service.";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "File containing the credentials to access the repository, in the format of an EnvironmentFile as described by `systemd.exec(5)`";
    };

    repoLocationFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to the file containing the repository location to backup to.";
    };

    repoPasswordFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to the file containing the repository password.";
    };

    sudoRules = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {options = sudoRuleOptions;});
      default = [];
      description = "List of additional sudo rules to grant the backup user.";
      example = ''
        nixfiles.backups.sudoRules = [
          { command = "myService --backup" }
        ];
      '';
    };
  };
}
