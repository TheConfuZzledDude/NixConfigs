# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
perSystemInputs @ {...}: {
  wg-netns = (import ./wg-netns.nix) perSystemInputs;
}
