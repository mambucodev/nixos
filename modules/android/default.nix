{ pkgs, ... }:

{
  # systemd 258 grants adb uaccess automatically — no adbusers group needed.
  environment.systemPackages = [ pkgs.android-tools ];
}
