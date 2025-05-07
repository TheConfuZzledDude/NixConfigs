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
  ];

  services.tailscale.enable = true;
  services.tailscale.openFirewall = true;

  services.nginx.enable = lib.mkForce false;

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

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
  in {
    enable = true;
    wantedBy = ["network-online.target"];
    serviceConfig = {
      Type = "notify";
      RestartSec = 5;
      KillMode = "none";
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
