{
  config,
  lib,
  ...
}: let
  cfg = config.nixfiles.paperless;
  consumeParentDir = builtins.toPath "${toString cfg.consumeDir}/..";
in {
  # It seems that chrooting using SFTP mandates that the chroot must be owned
  # by root:root and have 0755 permissions.
  #
  # This therefore means that in order for the a non-root user to be able to
  # upload files via SFTP, there must be another directory inside the chroot
  # that is writeable.
  #
  # The way this is handled here is by making the directory above the consume
  # dir the chroot, whilst the consume dir itself has permissions that allow
  # the paperless group to write into it.

  config = lib.mkIf (cfg.enable && cfg.enableSftp) {
    systemd.tmpfiles.settings = {
      "paperless-sftp" = {
        "${consumeParentDir}" = {
          d = {
            user = "root";
            group = "root";
            mode = "0755";
          };
        };
      };
    };

    services.openssh = {
      sftpServerExecutable = "internal-sftp";
      extraConfig = ''
        Match User ${config.users.users.paperless.name}
          ForceCommand internal-sftp
          ChrootDirectory ${consumeParentDir}
          PermitTunnel no
          AllowAgentForwarding no
          AllowTcpForwarding no
          X11Forwarding no
          PasswordAuthentication yes
        Match All
      '';
    };
  };
}
