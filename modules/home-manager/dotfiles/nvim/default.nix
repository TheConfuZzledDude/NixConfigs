{
  config,
  pkgs,
  lib,
  ...
} @ ctx: {
  config = {
    xdg.configFile = let
      nvim-path = "${config.home.homeDirectory}/${config.nix-config-path}/modules/home-manager/dotfiles/nvim/files";
    in {
      "nvim/init.lua".source = config.lib.file.mkOutOfStoreSymlink "${nvim-path}/init.lua";
      "nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink "${nvim-path}/lazy-lock.json";
      "nvim/lazyvim.json".source = config.lib.file.mkOutOfStoreSymlink "${nvim-path}/lazyvim.json";
      "nvim/neoconf.json".source = config.lib.file.mkOutOfStoreSymlink "${nvim-path}/neoconf.json";
      "nvim/stylua.toml".source = config.lib.file.mkOutOfStoreSymlink "${nvim-path}/stylua.toml";
      "nvim/lua/".source = config.lib.file.mkOutOfStoreSymlink "${nvim-path}/lua/";
    };

    programs.java.enable = true;
    programs.java.package = pkgs.temurin-bin;

    home.packages =
      [
        (pkgs.symlinkJoin
          {
            name = "neovim-wrapped-custom";
            paths = [pkgs.neovim];
            buildInputs = [pkgs.makeBinaryWrapper];
            postBuild = ''
              wrapProgram $out/bin/nvim \
                 --prefix LIBSQLITE : ${pkgs.sqlite.outPath}/lib/libsqlite3.so
            '';
          })
      ]
      ++ [
        pkgs.clang
        (lib.hiPrio pkgs.gcc)
        pkgs.llvmPackages.bintools
      ]
      ++ (with pkgs; [
        rustup
        ranger
        nodejs
        python3Full
        python3Packages.pip
        python3Packages.pynvim
        luajit
        luarocks
        go
        unzip
        sqlite.bin
        sqlite.out
        sqlite.dev
        nixd
        ripgrep
        fd
      ]);
  };
}
