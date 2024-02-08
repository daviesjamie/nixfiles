{config, ...}: {
  sops.secrets."backups/bucket/accessKey" = {};
  sops.secrets."backups/bucket/secretKey" = {};
  sops.secrets."backups/repo/location" = {owner = config.users.users.backups.name;};
  sops.secrets."backups/repo/password" = {owner = config.users.users.backups.name;};

  sops.templates."backups.env".content = ''
    AWS_ACCESS_KEY_ID="${config.sops.placeholder."backups/bucket/accessKey"}"
    AWS_SECRET_ACCESS_KEY="${config.sops.placeholder."backups/bucket/secretKey"}"
  '';

  nixfiles.backups.enable = true;
  nixfiles.backups.environmentFile = config.sops.templates."backups.env".path;
  nixfiles.backups.repoLocationFile = config.sops.secrets."backups/repo/location".path;
  nixfiles.backups.repoPasswordFile = config.sops.secrets."backups/repo/password".path;
}
