{
  config,
  lib,
  ...
}: let
  cfg = config.nixfiles.paperless;
in {
  config = lib.mkIf cfg.enable {
    sops.secrets."paperless/user/password" = {
      neededForUsers = true;
    };

    users.users.paperless = {
      description = "Paperless service user";
      uid = 995;
      isSystemUser = true;
      createHome = false;
      group = "paperless";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBJLkRU/0rnP7dYbZ/jRrl94vaDJvTi/JbwkZLDPIQOD jagd@makani"
      ];
      hashedPasswordFile = config.sops.secrets."paperless/user/password".path;
    };

    users.groups.paperless = {gid = 993;};

    services.openssh.sftpServerExecutable = "internal-sftp";
    services.openssh.extraConfig = ''
      Match User ${config.users.users.paperless.name}
        ForceCommand internal-sftp
        ChrootDirectory ${cfg.consumeDir}
        PermitTunnel no
        AllowAgentForwarding no
        AllowTcpForwarding no
        X11Forwarding no
      Match All
    '';
  };
}
