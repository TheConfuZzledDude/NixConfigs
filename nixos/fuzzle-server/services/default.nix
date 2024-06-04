{flake, lib, config, ...}: {
  imports = [
    ./vaultwarden
    ./caddy
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
    mail.dsn = "";

    # Can't disable this for some reason, is set to null by default, but not the correct type
    nginx = {};

  };
  services.nginx.enable = lib.mkForce false;
}
