{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./compose.nix
  ];

  sops.secrets.gluetun-env = {
    sopsFile = ./secrets.env;
    format = "dotenv";
    restartUnits = ["podman-gluetun.service"];
  };

  virtualisation.oci-containers.containers."gluetun".environmentFiles = [
    config.sops.secrets.gluetun-env.path
  ];
}
