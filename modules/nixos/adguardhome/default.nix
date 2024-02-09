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
          ports = [
            {
              # DNS
              host = 53;
              inner = 53;
            }
            {
              # Web interface
              host = cfg.port;
              inner = 80;
            }
            {
              # Intro wizard interface
              host = 3123;
              inner = 3000;
            }
          ];
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
