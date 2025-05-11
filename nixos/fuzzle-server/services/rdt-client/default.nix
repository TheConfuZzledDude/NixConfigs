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
    requires = ["podman-rdtclient.service" "proxy-to-rdtclient.socket"];
    after = ["podman-rdtclient.service" "proxy-to-rdtclient.socket"];
    serviceConfig = {
      ExecStart = ''
        socat tcp-listen:"6500",reuseaddr,fork "exec:ip netns exec mullvad socat stdio 'tcp-connect:6500',nofork"
      '';
      NetworkNamespacePath = "/var/run/netns/mullvad";
      PrivateNetwork = "yes";
    };
  };
}
