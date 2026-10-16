# Declarative disk layout — used ONLY to partition a NEW machine, never imported
# by the running system (each host keeps its generated hardware-configuration.nix).
#
# Mirrors Freetop's layout:
#   GPT
#   ├─ 1G   ESP (vfat)             → /boot
#   ├─ 17G  LUKS2 "cryptswap"      → swap (hibernation resumes from here)
#   └─ rest LUKS2 "cryptroot"      → btrfs
#         ├─ subvol root           → /
#         ├─ subvol nix            → /nix
#         └─ subvol home           → /home
#
# Swap must be at least the machine's RAM for hibernation; bump the size if needed.
# Set `device` to the target disk (lsblk). Everything on it is DESTROYED.
# See INSTALL.md for the full flow.
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
          swap = {
            label = "disk-main-swap";
            size = "17G";
            content = {
              type = "luks";
              name = "cryptswap";
              settings.allowDiscards = true;
              content = {
                type = "swap";
                resumeDevice = true;
              };
            };
          };
          root = {
            label = "disk-main-root";
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
                };
              };
            };
          };
        };
      };
    };
  };
}
