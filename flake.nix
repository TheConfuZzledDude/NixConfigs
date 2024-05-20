{
  description = "A fuzzy flake";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-flake.url = "github:srid/nixos-flake";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    lix = {
      url = "git+https://git@git.lix.systems/lix-project/lix?ref=refs/tags/2.90-beta.1";
      flake = false;
    };
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
      inputs.lix.follows = "lix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    experimental-features = "auto-allocate-uids flakes nix-command repl-flake";
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org"
      "https://cache.lix.systems"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
    ];
  };

  outputs = inputs @ {self, ...}:
    inputs.flake-parts.lib.mkFlake {inherit inputs;}
    {
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      imports = [
        inputs.nixos-flake.flakeModule
        ./modules/home-manager
      ];

      perSystem = {
        self',
        pkgs,
        lib,
        system,
        ...
      }: {
        nixos-flake.primary-inputs = [
          "nixpkgs"
          "home-manager"
          "nixos-flake"
          "neovim-nightly-overlay"
        ];

        packages =
          {
            default = self'.packages.activate;
            activate-home =
              lib.mkForce
              (pkgs.writeShellApplication
                {
                  name = "activate-home";
                  text = ''
                    set -x

                    for n in "$USER@$(hostname)" "$USER@$(hostname -s)" "$USER"; do
                      if [[ "$(nix eval ".#legacyPackages.${system}.homeConfigurations" --apply "x: x ? \"$n\"")" == "true" ]]; then
                          name="$n"
                          nix run \
                              .#legacyPackages.${system}.homeConfigurations."\"''${name}\"".activationPackage \
                              "$@"
                          exit 0
                      fi
                    done
                  '';
                });
          }
          // (import ./pkgs);
        formatter = pkgs.alejandra;

        legacyPackages.homeConfigurations = {
          # FIXME replace with your username@hostname
          zuzi = self.nixos-flake.lib.mkHomeConfiguration pkgs {
            imports = [
              self.homeManagerModules.standard
            ];
            targets.genericLinux.enable = true;
            home = {
              username = "zuzi";
              homeDirectory = "/home/zuzi";
            };
            systemd.user.startServices = "sd-switch";
            home.stateVersion = "24.05";
          };

          "zuzi@ZacharyNixWSL" = self.nixos-flake.lib.mkHomeConfiguration pkgs {
            imports = [
              self.homeManagerModules.standard
              self.homeMangerModules.wsl
            ];
            home = {
              username = "zuzi";
              homeDirectory = "/home/zuzi";
            };
            systemd.user.startServices = "sd-switch";
            home.stateVersion = "24.05";
          };
        };
      };

      debug = true;

      flake = {
        overlays = import ./overlays {inherit inputs;};
        # Reusable nixos modules you might want to export
        # These are usually stuff you would upstream into nixpkgs
        nixosModules = import ./modules/nixos;

        # NixOS configuration entrypoint
        # Available through 'nixos-rebuild --flake .#your-hostname'
        nixosConfigurations = {
          fuzzle-server-1 = self.nixos-flake.lib.mkLinuxSystem {
            nixpkgs.hostPlatform = "x86_64-linux";
            imports = [
              ./nixos/configuration.nix
              self.lix-module.nixosModules.default
              self.nixosModules.home-manager
              {
                home-manager.users.zuzi = {
                  imports = [
                    self.homeManagerModules.standard
                  ];
                  home.stateVersion = "24.05";
                };
              }
            ];
          };
        };
      };
    };
}
