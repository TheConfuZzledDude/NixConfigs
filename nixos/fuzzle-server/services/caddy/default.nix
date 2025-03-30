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
    inputs.nixpkgs.legacyPackages."x86_64-linux".caddy.withPlugins
    {
      plugins = ["github.com/caddy-dns/porkbun@v0.2.1"];
      hash = "sha256-X8QbRc2ahW1B5niV8i3sbfpe1OPYoaQ4LwbfeaWvfjg=";
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

  systemd.services.caddy = let
    additionalEnv = pkgs.writeText "caddy-additional-env.env" ''
      DAVIS_SOCKET_PATH=${config.services.phpfpm.pools.davis.socket}
      DAVIS_ROOT=${config.services.davis.package}/public
    '';
  in {
    restartIfChanged = true;
    restartTriggers = [./Caddyfile additionalEnv];
    serviceConfig.EnvironmentFile = lib.mkForce [
      config.sops.secrets.caddy-env.path
      additionalEnv
    ];
  };
  networking.firewall.allowedTCPPorts = [80 443];
}
