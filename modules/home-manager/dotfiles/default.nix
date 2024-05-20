{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./nvim
  ];

  options = {
    nix-config-path = pkgs.lib.mkOption {
      type = pkgs.lib.types.str;
      default = ".NixConfig";
      defaultText = ".NixConfig";
      description = "NixConfig directory";
    };
  };

  config = {
    home.extraActivationPath = with pkgs; [git openssh];

    home.activation = {
      myActivationAction = lib.hm.dag.entryAfter ["writeBoundary"] ''
        run --quiet git clone $VERBOSE_ARG "https://github.com/TheConfuZzledDude/NixConfigs.git" "$HOME/${config.nix-config-path}"  \
          || git -C "$HOME/${config.nix-config-path}" pull --ff-only || true
      '';
    };
  };
}
