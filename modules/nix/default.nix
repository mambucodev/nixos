{ ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # This flake lives at /etc/nixos and is edited constantly, so it's almost
  # always mid-change at rebuild time; silence the "Git tree is dirty" nag.
  nix.settings.warn-dirty = false;

  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [];

  # imageio 2.37.2's 16-bit PNG tests fail against nixpkgs' current Pillow
  # ("Invalid mode for data type"), which breaks alpaca's closure. Drop once
  # nixpkgs bumps imageio.
  nixpkgs.overlays = [
    (final: prev: {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (pyfinal: pyprev: {
          imageio = pyprev.imageio.overridePythonAttrs (old: {
            disabledTestPaths = (old.disabledTestPaths or [ ]) ++ [
              "tests/test_pillow.py::test_png_16bit"
              "tests/test_pillow_legacy.py::test_png"
            ];
          });
        })
      ];
    })
  ];
}
