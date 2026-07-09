{ ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/boot
    ../../modules/plymouth
    ../../modules/networking
    ../../modules/locale
    ../../modules/desktop
    ../../modules/audio
    ../../modules/shell
    ../../modules/users
    ../../modules/nix
    ../../modules/nix-ld
    ../../modules/fingerprint
    ../../modules/zed-overlay
    ../../modules/claude-code
    ../../modules/claude-cowork
    ../../modules/claude-flake-updates
    ../../modules/claude
    ../../modules/maintenance
    ../../modules/hardware
    ../../modules/oomd
    ../../modules/hibernation
    ../../modules/bluetooth
    ../../modules/avahi
    ../../modules/network-displays
    ../../modules/tailscale
    ../../modules/syncthing
    ../../modules/ollama
    ../../modules/steam
    ../../modules/xpad
    ../../modules/android
    ../../modules/kdeconnect
    ../../modules/containers
  ];

  networking.hostName = "freetop";

  system.stateVersion = "26.05";
}
