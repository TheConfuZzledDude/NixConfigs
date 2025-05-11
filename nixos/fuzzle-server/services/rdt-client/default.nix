{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Regenerate with `compose2nix --inputs=compose.yml --output=compose.nix`
    #TODO: Generate this automatically and import it with IFD?
    ./compose.nix
  ];

  systemd.services."proxy-to-rdtclient" = {
    enable = true;
    requires = ["podman-rdtclient.service"];
    after = ["podman-rdtclient.service"];
    path = [
      pkgs.iproute2
      pkgs.socat
    ];
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        socat tcp-listen:"6500",reuseaddr,fork "exec:ip netns exec mullvad socat stdio 'tcp-connect:6500',nofork"
      '';
      Restart = "on-failure";
    };
    wantedBy = ["multi-user.target"];
  };

  environment.systemPackages = [
    pkgs.socat
  ];
}
