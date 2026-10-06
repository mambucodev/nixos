{ inputs, ... }:

{
  # nixos-26.05 lags upstream claude-code; track the sadjow flake instead.
  nixpkgs.overlays = [ inputs.claude-code-nix.overlays.default ];
}
