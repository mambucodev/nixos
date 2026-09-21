{ pkgs, lib, ... }:

let
  extensionUuid = "bt-proximity-toggle@mambuco";

  bt-proximity-toggle-extension = pkgs.stdenv.mkDerivation {
    pname = "gnome-shell-extension-bt-proximity-toggle";
    version = "1.0.0";
    src = ./extension;

    installPhase = ''
      runHook preInstall
      extdir=$out/share/gnome-shell/extensions/${extensionUuid}
      mkdir -p "$extdir"
      cp -r * "$extdir/"
      runHook postInstall
    '';

    passthru.extensionUuid = extensionUuid;
  };

  bt-proximity-lock-bin = pkgs.writers.writePython3Bin "bt-proximity-lock" {
    libraries = [ ];
    flakeIgnore = [ "E501" "E265" "F541" ];
    makeWrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      (lib.makeBinPath [
        pkgs.bluez
        pkgs.systemd
        pkgs.glib
        pkgs.dbus
      ])
    ];
  } (builtins.readFile ./bt-proximity-lock.py);
in
{
  home.packages = [
    bt-proximity-lock-bin
    bt-proximity-toggle-extension
  ];

  xdg.configFile."bt-proximity-lock.conf".text = ''
    # Configuration for bt-proximity-lock
    # MAC address of your paired device (Pixel Watch 4)
    DEVICE_MAC="64:9D:38:1A:4F:5A"
    DEVICE_NAME="Pixel Watch 4"

    # Bluetooth Classic RSSI threshold:
    # 0 dB: Golden Receive Power Range (~0-2 meters)
    # Negative values: weaker signal (-3 to -6 dB typically corresponds to ~3-5m depending on walls/obstacles)
    RSSI_THRESHOLD=-4

    # Tolerance / Debounce:
    # Number of consecutive checks below threshold (or disconnected) before locking.
    # Prevents false locks from brief radio dips or body occlusion.
    TOLERANCE_COUNT=5

    # Check interval in seconds while laptop is unlocked
    POLL_INTERVAL=2.0

    # Check interval in seconds while laptop is ALREADY locked
    # When locked, proximity polling is suspended completely to save battery and CPU.
    LOCKED_INTERVAL=8.0

    # Pause MPRIS media players upon lock
    PAUSE_MEDIA=true
  '';

  systemd.user.services.bt-proximity-lock = {
    Unit = {
      Description = "Bluetooth Proximity Screen Locker (Pixel Watch 4)";
      Documentation = "file://${bt-proximity-lock-bin}/bin/bt-proximity-lock";
      After = [ "bluetooth.target" "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${bt-proximity-lock-bin}/bin/bt-proximity-lock";
      Restart = "always";
      RestartSec = "5s";
      Environment = [
        "PATH=${lib.makeBinPath [ pkgs.bluez pkgs.systemd pkgs.glib pkgs.dbus ]}:/run/current-system/sw/bin"
      ];
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
