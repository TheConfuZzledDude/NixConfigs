{
  lib,
  flake,
  pkgs,
  ...
}: let
  inherit (flake) inputs config self;
in {
  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      trusted-users = ["root" "@wheel"];
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
        "https://cache.lix.systems"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
      ];
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  nixpkgs = {
    overlays = [
      flake.inputs.neovim-nightly-overlay.overlays.default
    ];
    config = {allowUnfree = true;};
  };

  wsl.enable = true;
  wsl.defaultUser = "zuzi";
  wsl.useWindowsDriver = false;
  wsl.usbip.enable = true;
  wsl.usbip.autoAttach = [
    "2-2"
  ];

  programs.fish.enable = true;
  programs.fish.interactiveShellInit = ''
    export NIX_LD=(nix eval --impure --raw --expr 'let pkgs = import <nixpkgs> {}; NIX_LD = pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker"; in NIX_LD')
  '';

  users.defaultUserShell = pkgs.fish;

  programs.nix-ld.enable = true;

  networking.hostName = "ZacharyNixWSL";

  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;

  services.pcscd.enable = true;

  services.udev = {
    enable = true;
    packages = [pkgs.yubikey-personalization];
    extraRules = ''
      SUBSYSTEM=="usb", MODE="0666"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", TAG+="uaccess", MODE="0666"
    '';
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.tailscale.enable = true;
  services.tailscale.openFirewall = true;

  programs.ssh.enableAskPassword = false;
  networking.firewall.enable = true;
  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    usbutils
    gnupg
    gpg-tui
    git
    linuxPackages.usbip
    yubikey-manager
    libfido2
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
