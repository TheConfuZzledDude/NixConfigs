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

  sops.secrets.foundry-aws = {
    sopsFile = ./aws.json;
    uid = 421;
    key = "";
    restartUnits = ["podman-foundry-container-foundry.service"];
    format = "json";
  };

  virtualisation.oci-containers.containers."foundry-container-foundry".environmentFiles = [
    config.sops.secrets.foundry-env.path
  ];

  virtualisation.oci-containers.containers."foundry-container-foundry".environment."UV_THREADPOOL_SIZE" = "16";
}
