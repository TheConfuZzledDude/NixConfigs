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
}
