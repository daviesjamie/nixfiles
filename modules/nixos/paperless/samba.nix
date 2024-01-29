{
  config,
  lib,
  ...
}: let
  cfg = config.nixfiles.paperless;
in {
  config = lib.mkIf (cfg.enable && cfg.enableSamba) {
    services.samba = {
      enable = true;
      openFirewall = true;
      securityType = "user";
      extraConfig = ''
        workgroup = WORKGROUP
        server string = ${config.networking.hostName}
        netbios name = ${config.networking.hostName}
        security = user
        hosts allow = 192.168.1. 127.0.0.1 localhost
        hosts deny = 0.0.0.0/0
        guest account = nobody
        map to guest = bad user
      '';

      shares = {
        paperless = {
          path = "${toString cfg.consumeDir}";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "paperless";
          "force group" = "paperless";
        };
      };
    };
  };
}
