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

  fileSystems."/mnt/alldebrid" = {
    device = "AllDebrid:/";
    fsType = "rclone";
    options = [
      "nodev"
      "nofail"
      "allow_other"
      "args2env"
      "config=${config.sops.templates."rclone.conf".path}"
      "dir_cache_time=10s"
      "multi_thread_streams=0"
      "cutoff_mode=cautious"
      "vfs_cache_mode=minimal"
      "network_mode"
      "buffer_size=0"
      "read_only"
    ];
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
        /run/current-system/sw/bin/s3fs $\{BUCKET_NAME}:${mountPoint} -o url=$\{BUCKET_URL} -o use_cache=/tmp -o allow_other -o use_path_request_style
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
