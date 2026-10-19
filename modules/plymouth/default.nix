{ pkgs, ... }:

{
  # Stock bgrt: firmware (HP) logo + GNOME spinner, with the NixOS logo as the
  # bottom watermark (static, unlike nixos-bgrt's low-res spinning one).
  boot.plymouth = {
    enable = true;
    logo = "${pkgs.nixos-icons}/share/icons/hicolor/96x96/apps/nix-snowflake-white.png";
  };
  catppuccin.plymouth.enable = false;

  # Quiet boot so the splash isn't drowned in kernel/udev logs.
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "splash"
    "udev.log_priority=3"
    "rd.udev.log_level=3"
    "boot.shell_on_fail"
  ];
}
