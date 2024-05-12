{
  description = "A fuzzy flake";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    sops-nix.url = "github:Mic92/sops-nix";

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    self,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit self inputs;}
    ({
      self,
      inputs,
      withSystem,
      ...
    }: let
      inherit (self) outputs;
    in {
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      perSystem = {
        pkgs,
        lib,
        config,
        ...
      }: {
        packages = import ./pkgs pkgs;
        formatter = pkgs.alejandra;
      };

      debug = true;

      flake = {
        overlays = import ./overlays {inherit inputs;};
        # Reusable nixos modules you might want to export
        # These are usually stuff you would upstream into nixpkgs
        nixosModules = import ./modules/nixos;
        # Reusable home-manager modules you might want to export
        # These are usually stuff you would upstream into home-manager
        homeManagerModules = import ./modules/home-manager;

        # NixOS configuration entrypoint
        # Available through 'nixos-rebuild --flake .#your-hostname'
        nixosConfigurations = {
          fuzzle-server-1 = inputs.nixpkgs.lib.nixosSystem {
            specialArgs = {inherit inputs outputs;};
            modules = [
              # > Our main nixos configuration file <
              ./nixos/configuration.nix
            ];
          };
        };

        # Standalone home-manager configuration entrypoint
        # Available through 'home-manager --flake .#your-username@your-hostname'
        homeConfigurations = {
          # FIXME replace with your username@hostname
          "zuzi@ZacharyArchDesktop" = withSystem "x86_64-linux" (ctx @ {...}:
            inputs.home-manager.lib.homeManagerConfiguration {
              pkgs = inputs.nixpkgs-unstable.legacyPackages."x86_64-linux";
              extraSpecialArgs = {
                inherit inputs outputs;
              };
              modules = [
                # > Our main home-manager configuration file <
                ./home-manager/home.nix
              ];
            });
        };
      };
    });
}
