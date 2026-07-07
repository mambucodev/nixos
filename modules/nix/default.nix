{ ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # This flake lives at /etc/nixos and is edited constantly, so it's almost
  # always mid-change at rebuild time; silence the "Git tree is dirty" nag.
  nix.settings.warn-dirty = false;

  nixpkgs.config.allowUnfree = true;

  # Claude Desktop's Electron pin is flagged insecure routinely; bump the
  # version string here when the upstream pin moves.
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];
}
