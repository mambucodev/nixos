{ ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # This flake lives at /etc/nixos and is edited constantly, so it's almost
  # always mid-change at rebuild time; silence the "Git tree is dirty" nag.
  nix.settings.warn-dirty = false;

  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [];
}
