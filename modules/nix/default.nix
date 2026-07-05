{ ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Claude Desktop's Electron pin is flagged insecure routinely; bump the
  # version string here when the upstream pin moves.
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];
}
