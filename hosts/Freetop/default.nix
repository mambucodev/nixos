{ ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/boot
    ../../modules/plymouth
    ../../modules/networking
    ../../modules/locale
    ../../modules/desktop
    ../../modules/gnome-catppuccin
    ../../modules/catppuccin
    ../../modules/chromium-policies
    ../../modules/fonts
    ../../modules/audio
    ../../modules/shell
    ../../modules/users
    ../../modules/nix
    ../../modules/nix-ld
    ../../modules/fingerprint
    ../../modules/claude-code
    ../../modules/antigravity-flake-updates
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
    ../../modules/packet
    ../../modules/containers
    ../../modules/beamer
  ];

  boot.initrd.luks.devices = {
    "luks-0abadf3f-6ef6-4c6c-81e3-7d442351a313".crypttabExtraOpts = [ "tpm2-device=auto" ];
    "luks-55909935-cc54-46ed-8bbf-47d8c7decaa5".crypttabExtraOpts = [ "tpm2-device=auto" ];
  };
  security.tpm2.enable = true;

  networking.hostName = "Freetop";

  system.stateVersion = "26.05";
}
