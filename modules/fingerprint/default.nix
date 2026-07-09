{ inputs, pkgs, ... }:

{
  # depau/libfprint elanmoc2 branch: adds this laptop's Elan 04f3:0c5e reader.
  nixpkgs.overlays = [
    (final: prev: {
      libfprint = prev.libfprint.overrideAttrs (_: {
        src = inputs.depau-libfprint;
        # nixpkgs cherry-picks upstream device-ID patches onto its pinned
        # source; they don't apply to the fork's tree (realtek hunk fails).
        # The fork carries our reader (Elan 04f3:0c5e) itself, so drop them.
        patches = [ ];
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

  # The fork has no suspend support: a USB transfer left in flight across
  # sleep trips g_assert_null(in_flight_cmd) and aborts fprintd mid-resume,
  # wedging the PAM conversation (black lock screen). Stop it before sleep;
  # D-Bus activation brings it back on demand.
  systemd.services.fprintd.serviceConfig.Restart = "on-failure";
  systemd.services.fprintd-pre-sleep = {
    description = "Stop fprintd before sleep";
    wantedBy = [ "sleep.target" ];
    before = [ "sleep.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl stop fprintd.service";
    };
  };

  # sudo + graphical login by fingerprint (GDM uses the gdm-password stack).
  security.pam.services = {
    sudo.fprintAuth = true;
    gdm-password.fprintAuth = true;
  };
}
