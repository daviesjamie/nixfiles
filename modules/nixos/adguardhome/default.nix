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
              {
                # DNS
                host = 53;
                inner = 53;
                expose = true;
              }
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
