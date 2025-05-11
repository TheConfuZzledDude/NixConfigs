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

  # systemd.services."podman-rdtclient" = {
  #   serviceConfig = {
  #     NetworkNamespacePath = "/var/run/netns/mullvad";
  #     BindReadOnlyPaths = "/etc/netns/mullvad/resolv.conf:/etc/resolv.conf:norbind";
  #   };
  # };
  #
  systemd.services."proxy-to-rdtclient" = {
    enable = true;
    requires = ["podman-rdtclient.service" "proxy-to-rdtclient.socket"];
    after = ["podman-rdtclient.service" "proxy-to-rdtclient.socket"];
    serviceConfig = {
      ExecStart = "/run/current-system/sw/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:6500";
      NetworkNamespacePath = "/var/run/netns/mullvad";
      PrivateNetwork = "yes";
    };
  };

  systemd.sockets."proxy-to-rdtclient" = {
    enable = true;
    listenStreams = ["6500"];
    wantedBy = ["sockets.target"];
  };
}
