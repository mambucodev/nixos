{ pkgs, ... }:

{
  # GSConnect (GNOME-native KDE Connect); the NixOS option still opens the
  # TCP/UDP 1714–1764 range. Shell extension is enabled in home/mambuco/gnome.
  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };
}
