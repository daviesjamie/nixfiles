{config, lib, ...}: let
  cfg = config.nixfiles.paperless;
in {
  config = lib.mkIf cfg.enable {
    sops.secrets."paperless/user/password" = {
      neededForUsers = true;
    };

    users.users.paperless = {
      description = "Paperless service user";
      isSystemUser = true;
      createHome = false;
      group = "paperless";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBJLkRU/0rnP7dYbZ/jRrl94vaDJvTi/JbwkZLDPIQOD jagd@makani"
      ];
      hashedPasswordFile = config.sops.secrets."paperless/user/password".path;
    };

    users.groups.paperless = {};
  };
}
