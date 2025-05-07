perSystemInputs @ {
  self',
  inputs,
  pkgs,
  ...
}: let
  inherit (inputs.poetry2nix.lib.mkPoetry2Nix {inherit pkgs;}) mkPoetryApplication;
in
  mkPoetryApplication {
    projectDir = builtins.fetchGit {
      url = "https://github.com/dadevel/wg-netns.git";
      rev = "af199149ddc65e11a7644317d6c6fd88eb4eef02";
    };
  }
