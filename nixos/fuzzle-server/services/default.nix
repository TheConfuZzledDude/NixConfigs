{
  flake,
  lib,
  config,
  ...
}: {
  imports = [
    ./vaultwarden
    ./caddy
    ./foundry
  ];

  services.tailscale.enable = true;
  services.tailscale.openFirewall = true;

  sops.secrets."davis/appSecret".owner = config.services.davis.user;
  sops.secrets."davis/adminPassword".owner = config.services.davis.user;

  services.davis = {
    enable = true;
    hostname = "davis.fuzzle.uk";
    adminLogin = "admin";
    adminPasswordFile = config.sops.secrets."davis/adminPassword".path;
    appSecretFile = config.sops.secrets."davis/appSecret".path;
    mail.dsn = "smtp://username:password@example.com:25";
    mail.inviteFromAddress = "";

    # Can't disable this for some reason, is set to null by default, but not the correct type
    nginx = {};

    config = {
        LOG_FILE_PATH = lib.mkForce "php://stderr";
    };

    poolConfig = {
      "listen.owner" = config.services.caddy.user;
      "listen.group" = config.services.caddy.group;
      "catch_workers_output" = true;
      "decorate_workers_output" = false;
    };
  };

  services.phpfpm.pools.davis.phpOptions = lib.mkForce "";
  services.nginx.enable = lib.mkForce false;
}
