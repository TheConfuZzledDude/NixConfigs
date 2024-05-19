# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  self',
  inputs,
  inputs',
  outputs,
  lib,
  config,
  pkgs,
  system,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    outputs.homeManagerModules.dotfiles

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  targets.genericLinux.enable = true;

  # TODO: Set your username
  home = {
    username = "zuzi";
    homeDirectory = "/home/zuzi";
  };

  xdg.enable = true;

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;

  # Enable home-manager and git

  # programs.home-manager.enable = true;

  home.packages = with pkgs; [
    (pkgs.symlinkJoin
      {
        name = "home-manager-wrapped";
        paths = [inputs.home-manager.packages.${system}.home-manager];
        buildInputs = [pkgs.makeBinaryWrapper];
        postBuild = ''
          wrapProgram $out/bin/home-manager \
            --add-flags "-I" \
            --add-flags "home-manager/home-manager/build-news.nix=${inputs.home-manager.sourceInfo.outPath}/home-manager/build-news.nix" \
            --add-flags "--flake ${config.home.homeDirectory}/${config.nix-config-path}"
        '';
      })
    gitFull
    gcc
    gitui
    openssh
    gpg-tui
    gnupg
    yazi
    wl-clipboard
    bat
    fd
    ripgrep
    ripgrep-all
    gh
    zoxide
    wslu
  ];

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
