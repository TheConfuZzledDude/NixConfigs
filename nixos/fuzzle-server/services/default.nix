{
  flake,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./vaultwarden
    ./caddy
    ./foundry
    ./shoko
    ./wg-netns
    ./rdt-client
    ./gluetun
  ];

  services.tailscale.enable = true;
  services.tailscale.openFirewall = true;

  services.nginx.enable = lib.mkForce false;

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  services.sonarr.enable = true;
  services.radarr.enable = true;
  services.lidarr.enable = true;
  services.readarr.enable = true;
  services.jackett.enable = true;
  services.prowlarr.enable = true;
  services.kavita.enable = true;

  sops.secrets."rclone/adUser" = {};
  sops.secrets."rclone/adPass" = {};

  sops.templates."rclone.conf".content = ''
    [AllDebrid]
    type = webdav
    url = https://webdav.debrid.it/
    vendor = other
    user = ${config.sops.placeholder."rclone/adUser"}
    pass = ${config.sops.placeholder."rclone/adPass"}
  '';

  systemd.tmpfiles.settings.rcloneDirs = {
    "/var/cache/rclone"."d" = {
      mode = "700";
    };
  };

  systemd.services.alldebrid_mount = let
    mountPoint = "/mnt/alldebrid";
    proxy_addr = "127.0.0.1:8888";
  in {
    enable = true;
    wantedBy = ["network-online.target"];
    environment = {
      http_proxy = proxy_addr;
      https_proxy = proxy_addr;
    };
    serviceConfig = {
      Type = "notify";
      RestartSec = 5;
      ExecStartPre = "/run/current-system/sw/bin/mkdir -p ${mountPoint}";
      ExecStart = ''
        /run/current-system/sw/bin/rclone mount AllDebrid:/ ${mountPoint} \
            --config=${config.sops.templates."rclone.conf".path} \
            --cache-dir=/var/cache/rclone \
            --dir-cache-time 10s \
            --multi-thread-streams=0 \
            --cutoff-mode=cautious \
            --vfs-cache-mode=minimal \
            --network-mode \
            --buffer-size=0 \
            --read-only \
            --allow-other
      '';
    };
  };

  sops.secrets.s3fs_env = {
    sopsFile = ./s3fs.env;
    format = "dotenv";
    restartUnits = ["s3fs_media.service"];
  };

  systemd.services.s3fs_media = let
    mountPoint = "/media";
  in {
    enable = true;
    wants = ["network-online.target"];
    after = ["network-online.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      EnvironmentFile = "${config.sops.secrets.s3fs_env.path}";
      ExecStartPre = "/run/current-system/sw/bin/mkdir -p ${mountPoint}";
      ExecStart = ''
        /run/current-system/sw/bin/s3fs ''${BUCKET_NAME}:/ ${mountPoint} -o url=''${BUCKET_URL} -o use_cache=/tmp -o allow_other -o use_path_request_style
      '';
      ExecStop = "/run/wrappers/bin/fusermount -u ${mountPoint}";
    };
  };

  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
    pkgs.rclone
    pkgs.s3fs
    pkgs.fuse
  ];
}
