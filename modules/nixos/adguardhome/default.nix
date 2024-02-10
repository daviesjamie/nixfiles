{
  config,
  lib,
  ...
}: let
  cfg = config.nixfiles.adguardhome;
in {
  imports = [
    ./options.nix
  ];

  config = lib.mkIf cfg.enable {
    nixfiles.containers.pods.adguardhome = {
      containers = {
        adguardhome = {
          image = "adguard/adguardhome:${cfg.imageTag}";
          ports =
            [
              # DNS
              "0.0.0.0:53:53/tcp"
              "0.0.0.0:53:53/udp"
            ]
            ++ (
              if cfg.exposeWizard
              then [
                {
                  # Initial set-up wizard
                  host = cfg.port;
                  inner = 3000;
                }
              ]
              else [
                {
                  # Web interface
                  host = cfg.port;
                  inner = 80;
                }
              ]
            );
          volumes = [
            {
              name = "data";
              inner = "/opt/adguardhome/work";
            }
            {
              name = "config";
              inner = "/opt/adguardhome/conf";
            }
          ];
        };
      };
    };
  };
}
