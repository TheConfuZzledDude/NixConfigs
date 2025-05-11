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
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.socat}/bin/socat tcp-listen:"6500",reuseaddr,fork "exec:${pkgs.iproute2}/bin/ip netns exec mullvad ${pkgs.socat}/bin/socat stdio 'tcp-connect:127.0.0.1:6500',nofork"
      '';
      Restart = "on-failure";
    };
    wantedBy = ["multi-user.target"];
  };

  environment.systemPackages = [
    pkgs.socat
  ];
}
