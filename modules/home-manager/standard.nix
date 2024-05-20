# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  flake,
  pkgs,
  ...
}: {
  imports = [
    flake.self.homeManagerModules.dotfiles
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      flake.inputs.neovim-nightly-overlay.overlays.default
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  xdg.enable = true;

  home.packages = with pkgs; [
    home-manager
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
  ];
}
