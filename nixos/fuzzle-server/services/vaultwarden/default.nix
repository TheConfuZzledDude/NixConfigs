{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Regenerate with `compose2nix --inputs=compose.yml --output=compose.nix`
    #TODO: Generate this automatically and import it with IFD?
    ./compose.nix
  ];

  sops.secrets.vaultwarden-env = {
    sopsFile = ./secrets.env;
    format = "dotenv";
    restartUnits = ["podman-vaultwarden.service"];
  };

  virtualisation.oci-containers.containers."vaultwarden".environmentFiles = [
    config.sops.secrets.vaultwarden-env.path
  ];
}
