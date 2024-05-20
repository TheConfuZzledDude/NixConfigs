# Add your reusable home-manager modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  self,
  config,
  ...
}: {
  flake = {
    homeManagerModules = {
      standard.imports = [./standard.nix];
      dotfiles.imports = [./dotfiles];
      wsl.imports = [./wsl.nix];
    };
  };
}
