{
  getSystem,
  flake,
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (flake) inputs;
  caddy_pkg =
    pkgs.caddy.withPlugins
    {
      plugins = ["github.com/caddy-dns/porkbun@v0.3.1"];
      hash = "sha256-YZ4Bq0hfOJpa0C2lKipEY4fqwzJbEFM7ci5ys9S3uAo=";
    };
  # pkgs.callPackage
  # ./custom-caddy.nix
  # {
  #   externalPlugins = [
  #     {
  #       name = "caddy-dns/porkbun";
  #       repo = "github.com/caddy-dns/porkbun";
  #       version = "4267f6797bf6543d7b20cdc8578a31764face4cf";
  #     }
  #   ];
  #   vendorHash = "sha256-Uy2vq+mEIUs5MMVvLy6G7A308MCjoT2SqKv/I0yDK5w="; # Add this, as explained in https://github.com/NixOS/nixpkgs/pull/259275#issuecomment-1763478985
  # };
in {
  services.caddy = {
    enable = true;
    package = caddy_pkg;
    configFile = ./Caddyfile;
  };

  sops.secrets.caddy-env = {
    sopsFile = ./secrets.env;
    format = "dotenv";
    restartUnits = ["caddy.service"];
    owner = config.services.caddy.user;
    group = config.services.caddy.group;
  };

  environment.systemPackages = [
    caddy_pkg
  ];

  systemd.services.caddy = {
    restartIfChanged = true;
    restartTriggers = [./Caddyfile];
    serviceConfig.EnvironmentFile = lib.mkForce [
      config.sops.secrets.caddy-env.path
    ];
  };
  networking.firewall.allowedTCPPorts = [80 443];
}
