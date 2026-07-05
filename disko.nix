# Declarative disk layout — used ONLY to partition a NEW machine, never imported
# by the running system (freetop keeps its generated hardware-configuration.nix).
#
# Reproduces freetop's layout:
#   GPT
#   ├─ 1G  ESP (vfat)            → /boot
#   └─ rest LUKS2 "cryptroot"    → btrfs
#         ├─ subvol root         → /
#         ├─ subvol nix          → /nix
#         ├─ subvol home         → /home
#         └─ subvol swap         → /.swapvol  (16G swapfile, enables hibernation)
#
# Set `device` to the target disk (lsblk). Everything on it is DESTROYED.
# See README.md → "Installing on a new machine" for the full flow.
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            label = "disk-main-ESP";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "fmask=0077" "dmask=0077" ];
            };
          };
          luks = {
            label = "disk-main-luks";
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              settings.allowDiscards = true;
              # Prompts for the passphrase interactively at format time.
              # For an unattended install set: passwordFile = "/tmp/secret.key";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "/root" = { mountpoint = "/"; };
                  "/nix"  = { mountpoint = "/nix"; };
                  "/home" = { mountpoint = "/home"; };
                  "/swap" = {
                    mountpoint = "/.swapvol";
                    swap.swapfile.size = "16G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
