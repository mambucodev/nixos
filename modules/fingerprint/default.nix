{ inputs, ... }:

{
  # depau/libfprint elanmoc2 branch: adds this laptop's Elan 04f3:0c5e reader.
  nixpkgs.overlays = [
    (final: prev: {
      libfprint = prev.libfprint.overrideAttrs (_: {
        src = inputs.depau-libfprint;
        # Branch lacks tests/test-runner.sh that nixpkgs' postPatch expects;
        # rewrite the python test shebangs meson runs at configure time instead.
        postPatch = ''
          for f in tests/*.py; do
            substituteInPlace "$f" \
              --replace-quiet "#!/usr/bin/env python3" "#!${prev.python3}/bin/python3" \
              --replace-quiet "#! /usr/bin/env python3" "#!${prev.python3}/bin/python3"
          done
          patchShebangs tests/
        '';
        # Fork's tests assert pre-elanmoc2 feature flags.
        doInstallCheck = false;
      });
    })
  ];

  services.fprintd.enable = true;

  # sudo + graphical login by fingerprint (GDM uses the gdm-password stack).
  security.pam.services = {
    sudo.fprintAuth = true;
    gdm-password.fprintAuth = true;
  };
}
