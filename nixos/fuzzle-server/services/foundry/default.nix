{config, ...}: {
  imports = [
    # Regenerate with `compose2nix --inputs=compose.yml --output=compose.nix`
    #TODO: Generate this automatically and import it  with IFD?
    ./compose.nix
  ];

  sops.secrets.foundry-env = {
    sopsFile = ./secrets.env;
    format = "dotenv";
    restartUnits = ["podman-foundry-container-foundry.service"];
  };

  virtualisation.oci-containers.containers."foundry-container-foundry".environmentFiles = [
    config.sops.secrets.foundry-env.path
  ];
}
