{ inputs, ... }:

{
  # 26.05 lags Zed; pull just zed-editor from nixpkgs master (latest stable).
  nixpkgs.overlays = [
    (final: prev: {
      zed-editor = inputs.nixpkgs-zed.legacyPackages.${prev.system}.zed-editor;
    })
  ];
}
