{...}: {
  sops.secrets."mullvad.json" = {
    sopsFile = ./mullvad.json;
    format = "json";
    path = "/etc/wireguard/mullvad.json";
    mode = "0600";
    key = "";
  };

  systemd.services."wg-netns@.service" = {
    enable = true;
    wants = ["network-online.target" "nss-lookup.target"];
    after = ["network-online.target" "nss-lookup.target"];
    wantedBy = ["multi-user.target"];
    environment = {
      WG_ENDPOINT_RESOLUTION_RETRIES = "infinity";
      WG_VERBOSE = "1";
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/wg-netns up %i";
      ExecStop = "/run/current-system/sw/bin/wg-netns down %i";
      RemainAfterExit = "yes";
      WorkingDirectory = "%E/wireguard";
      ConfigurationDirectory = "wireguard";
      ConfigurationDirectoryMode = 0700;
      CapabilityBoundingSet = "CAP_NET_ADMIN CAP_SYS_ADMIN";
      LimitNOFILE = 4096;
      LimitNPROC = 512;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      ProtectClock = true;
      ProtectHostname = true;
      RemoveIPC = true;
      RestrictAddressFamilies = "AF_INET AF_INET6 AF_NETLINK";
      RestrictNamespaces = "mnt net";
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
    };
  };
}
