{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  config = {
    xdg.configFile = let
      nvim-path = "/home/zuzi/projects/all/NixConfigs/modules/home-manager/dotfiles/nvim/files";
    in {
      "nvim/init.lua".source = config.lib.file.mkOutOfStoreSymlink "${nvim-path}/init.lua";
      "nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink "${nvim-path}/lazy-lock.json";
      "nvim/lazyvim.json".source = config.lib.file.mkOutOfStoreSymlink "${nvim-path}/lazyvim.json";
      "nvim/neoconf.json".source = config.lib.file.mkOutOfStoreSymlink "${nvim-path}/neoconf.json";
      "nvim/stylua.toml".source = config.lib.file.mkOutOfStoreSymlink "${nvim-path}/stylua.toml";
      "nvim/lua/".source = config.lib.file.mkOutOfStoreSymlink "${nvim-path}/lua/";
    };
  };
}
