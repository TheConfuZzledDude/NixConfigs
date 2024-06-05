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
