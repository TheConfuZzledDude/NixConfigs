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

  sops.secrets."davis/appSecret".owner = config.services.davis.user;
  sops.secrets."davis/adminPassword".owner = config.services.davis.user;

  services.davis = {
    enable = true;
    hostname = "davis.fuzzle.uk";
    adminLogin = "admin";
    adminPasswordFile = config.sops.secrets."davis/adminPassword".path;
    appSecretFile = config.sops.secrets."davis/appSecret".path;
    mail.dsn = "smtp://username:password@example.com:25";
    mail.inviteFromAddress = "";

    # Can't disable this for some reason, is set to null by default, but not the correct type
    nginx = {};

    config = {
      LOG_FILE_PATH = lib.mkForce "php://stderr";
    };

    poolConfig = {
      "listen.owner" = config.services.caddy.user;
      "listen.group" = config.services.caddy.group;
      "catch_workers_output" = true;
      "decorate_workers_output" = false;
    };
  };

  services.phpfpm.pools.davis.phpOptions = lib.mkForce "";
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
        /run/current-system/sw/bin/s3fs $BUCKET_NAME:${mountPoint} -o url=$BUCKET_URL -o use_cache=/tmp -o allow_other -o use_path_request_style
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
