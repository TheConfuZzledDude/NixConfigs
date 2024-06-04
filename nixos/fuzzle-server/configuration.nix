# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  flake,
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (flake) inputs self;
in {
  # You can import other NixOS modules here
  imports = [
    inputs.sops-nix.nixosModules.sops
    # If you want to use modules your own flake exports (from modules/nixos):
    # self.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix

    ./services
  ];

  sops.defaultSopsFile = ../../secrets.yaml;
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  # This is using an age key that is expected to already be in the filesystem
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  # This will generate a new key if the key specified above does not exist
  sops.age.generateKey = true;
  # This is the actual specification of the secrets.

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      trusted-users = ["root" "@wheel"];
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  programs.fish.enable = true;

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "fuzzle-server-1";
  networking.domain = "";
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
  };

  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {
      dns_enabled = true;
      ipv6_enabled = true;
    };
  };
  virtualisation.oci-containers.backend = "podman";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 80 443];

    interfaces.podman1 = {
      allowedUDPPorts = [53];
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDSOwwDF4+bZXHPjOAUnK9zOQAN/A5BHVNhv5YzSfaS5laH3DIen0UV/YJkYoDorZ13cppCqWHXKsjvOjxz2B/A4SluKlPGsS+p81QB/5Pifr3UDvrSul9KmfMLgbGYzCzZmETEIgvIIbuLNAwuvLBbMqWO5JRNwa3p25CPdLc3MyDsthoAuRA9R2WHM1BH9JuaCbEHnR5cZlqhih4VcS7Kjfax1RXX0cjAkTRV//4HxjRfvlNta6O5CmdLnsNSa36UZchw3dLFICKGaEE71O30Tf8TTcxYjYzlUcgdqFpxXO6NNefjOzNOy8Su5L4npWRek7CJoq7wGrH5yXO9SzvwYKSsInTTufNxNEUM7wn075hCFlwE1msDcFeczrl1sCLdt8TqJUHCN0o/XDvCfJ8v6sAe0bN1/O82wsNhXY22B6HlzgSkIZnpVqTRJ0oqJzWyXfZc0LlapTmSjsiDQCMMkUy3qSLTsh18k4bwkgIFWS/70hYdjn7U26KwZZ2TnibOwZiqrW/pVlSIRs5bGI5i1cmEe4+oR/sX1izdwjg2WTeOwuIEPpuIdbT2umvoGslQUBHhVk+ZnNslnIvQfQAPEL/OIWCFJxARD05YsIcqk532EPOluWbBPkdChZfOmE8/DMPKs3kl+cUV9lAXM3U2EDzmFIGE4dMy38tnqAlqfw== theconfuzzleddude@gmail.com''
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHYqrXFKJp9OqGrCGQwywCqnh10p69qOAAfHjRGy4bZr zuzi@ZacharyArchDesktop''
    ''sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIN6yJ7qx+PMBAm5uO+1q96ldxLJwuy6kOOgKYBARzl9OAAAADHNzaDpZdWJpS2V5NQ== zuzi@ZacharyArchDesktop''
  ];

  services.fail2ban = {
    enable = true;
    ignoreIP = [
      "90.205.192.100"
      "2a02:c7c:6629:b700:5ca9:8a43:51b5:db15"
    ];
  };

  users.mutableUsers = false;

  sops.secrets."passwords/zuzi".neededForUsers = true;
  users.extraUsers.zuzi = {
    isNormalUser = true;
    home = "/home/zuzi";
    extraGroups = ["wheel" "networkmanager"];
    hashedPasswordFile = config.sops.secrets."passwords/zuzi".path;
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDSOwwDF4+bZXHPjOAUnK9zOQAN/A5BHVNhv5YzSfaS5laH3DIen0UV/YJkYoDorZ13cppCqWHXKsjvOjxz2B/A4SluKlPGsS+p81QB/5Pifr3UDvrSul9KmfMLgbGYzCzZmETEIgvIIbuLNAwuvLBbMqWO5JRNwa3p25CPdLc3MyDsthoAuRA9R2WHM1BH9JuaCbEHnR5cZlqhih4VcS7Kjfax1RXX0cjAkTRV//4HxjRfvlNta6O5CmdLnsNSa36UZchw3dLFICKGaEE71O30Tf8TTcxYjYzlUcgdqFpxXO6NNefjOzNOy8Su5L4npWRek7CJoq7wGrH5yXO9SzvwYKSsInTTufNxNEUM7wn075hCFlwE1msDcFeczrl1sCLdt8TqJUHCN0o/XDvCfJ8v6sAe0bN1/O82wsNhXY22B6HlzgSkIZnpVqTRJ0oqJzWyXfZc0LlapTmSjsiDQCMMkUy3qSLTsh18k4bwkgIFWS/70hYdjn7U26KwZZ2TnibOwZiqrW/pVlSIRs5bGI5i1cmEe4+oR/sX1izdwjg2WTeOwuIEPpuIdbT2umvoGslQUBHhVk+ZnNslnIvQfQAPEL/OIWCFJxARD05YsIcqk532EPOluWbBPkdChZfOmE8/DMPKs3kl+cUV9lAXM3U2EDzmFIGE4dMy38tnqAlqfw== theconfuzzleddude@gmail.com''
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHYqrXFKJp9OqGrCGQwywCqnh10p69qOAAfHjRGy4bZr zuzi@ZacharyArchDesktop''
      ''sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIN6yJ7qx+PMBAm5uO+1q96ldxLJwuy6kOOgKYBARzl9OAAAADHNzaDpZdWJpS2V5NQ== zuzi@ZacharyArchDesktop''
    ];
  };

  security.sudo = {
    enable = true;
    execWheelOnly = true;
  };

  programs.neovim = {
    vimAlias = true;
    viAlias = true;
    enable = true;
  };

  environment.variables.EDITOR = "nvim";

  environment.systemPackages = with pkgs; [
    wezterm
    zellij
    eza
    ripgrep
    ripgrep-all
    fish
    neovim
    bat
    git
    wget
    curl
    podman-tui
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
