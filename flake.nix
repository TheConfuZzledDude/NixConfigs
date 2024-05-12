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

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  nixConfig = {
    experimental-features = "auto-allocate-uids flakes nix-command repl-flake";
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = inputs @ {
    self,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;}
    ({
      inputs,
      withSystem,
      ...
    }: let
      self = inputs.self;
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
        inputs',
        pkgs,
        lib,
        config,
        system,
        ...
      } @ ctx: {
        packages = import ./pkgs ({inherit inputs;} // ctx);
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
          "zuzi@ZacharyArchDesktop" = withSystem "x86_64-linux" (ctx @ {
            system,
            inputs',
            self',
            ...
          }:
            inputs.home-manager.lib.homeManagerConfiguration {
              pkgs = import inputs.nixpkgs-unstable {
                inherit system;
                overlays = [
                  inputs.neovim-nightly-overlay.overlays.default
                ];
              };
              extraSpecialArgs = {
                inherit outputs inputs inputs' self' system;
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
