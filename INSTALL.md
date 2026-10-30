# NixOS Installation & Deployment Guide

This document provides a comprehensive, step-by-step walkthrough for installing and deploying this NixOS flake on a machine. It covers partitioning via `disko`, configuring host hardware declarations, adapting or adding custom hosts, running `nixos-install`, and completing post-installation security and environment setup.

---

## 📋 Table of Contents

- [1. Prerequisites & Live ISO Setup](#1-prerequisites--live-iso-setup)
- [2. Host Configuration Strategies](#2-host-configuration-strategies)
  - [Option A: Replacing the Existing Freetop Host](#option-a-replacing-the-existing-freetop-host)
  - [Option B: Creating a Custom New Host](#option-b-creating-a-custom-new-host)
- [3. Disk Partitioning & Formatting (Disko)](#3-disk-partitioning--formatting-disko)
- [4. Generating Hardware Configuration](#4-generating-hardware-configuration)
- [5. System Installation](#5-system-installation)
- [6. Post-Installation & Initial Setup](#6-post-installation--initial-setup)
- [7. Troubleshooting & Gotchas](#7-troubleshooting--gotchas)

---

## 1. Prerequisites & Live ISO Setup

1. **Download NixOS ISO:** Download the latest 24.11 or 26.05 NixOS Graphical (GNOME) or Minimal Live ISO from [nixos.org](https://nixos.org/download.html).
2. **Flash to USB:** Write the ISO image to a USB flash drive using `dd`, Ventoy, or Rufus.
3. **Boot in UEFI Mode:** Boot the target machine into the USB drive in **UEFI mode** (ensure Legacy/CSM boot is disabled in BIOS/UEFI settings). Secure Boot can be temporarily set to Setup Mode or disabled during installation.
4. **Connect to Internet:**
   - Wi-Fi: Run `nmtui` or `nmcli dev wifi connect <SSID> password <PASSWORD>`
   - Ethernet: Plug in cable (automatic DHCP).
5. **Acquire Repo Files:** Clone or copy this repository into the installer environment:
   ```bash
   git clone https://github.com/mambuco/nixos-config.git /tmp/nixos-config
   cd /tmp/nixos-config
   ```

---

## 2. Host Configuration Strategies

Before performing the installation, decide whether you are replacing the default **Freetop** host or adding a **new custom host**.

### Option A: Replacing the Existing `Freetop` Host

Use this approach if you are replacing the original machine and keeping `Freetop` as the hostname.

1. Keep `./hosts/Freetop/default.nix`.
2. Hardware settings in `hosts/Freetop/hardware-configuration.nix` will be overwritten during step 4.

### Option B: Creating a Custom New Host

Use this approach if you want to define a new hostname (e.g., `MyLaptop` or `Workstation`) alongside existing configurations.

1. **Create the new host directory:**
   ```bash
   mkdir -p hosts/MyLaptop
   ```

2. **Create `hosts/MyLaptop/default.nix`:**
   Copy from `hosts/Freetop/default.nix` and adjust the module imports and `networking.hostName`:

   ```nix
   { ... }:

   {
     imports = [
       ./hardware-configuration.nix

       ../../modules/boot
       ../../modules/plymouth
       ../../modules/networking
       ../../modules/locale
       ../../modules/desktop
       ../../modules/chromium-policies
       ../../modules/fonts
       ../../modules/audio
       ../../modules/shell
       ../../modules/users
       ../../modules/nix
       ../../modules/nix-ld
       ../../modules/fingerprint        # Remove if target lacks Elan fingerprint sensor
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
       ../../modules/containers
     ];

     networking.hostName = "MyLaptop";
     system.stateVersion = "26.05";
   }
   ```

3. **Register the new host in `flake.nix`:**
   Open `flake.nix` and add a new output configuration under `nixosConfigurations`:

   ```nix
   outputs = { self, nixpkgs, lanzaboote, home-manager, ... }@inputs: {
     nixosConfigurations.Freetop = nixpkgs.lib.nixosSystem { ... };

     # New host definition
     nixosConfigurations.MyLaptop = nixpkgs.lib.nixosSystem {
       specialArgs = { inherit inputs; };
       modules = [
         ./hosts/MyLaptop

         lanzaboote.nixosModules.lanzaboote

         home-manager.nixosModules.home-manager
         {
           home-manager.useGlobalPkgs = true;
           home-manager.useUserPackages = true;
           home-manager.backupFileExtension = "hm-backup";
           home-manager.extraSpecialArgs = { inherit inputs; };

           home-manager.users.mambuco = import ./home/mambuco;
         }
       ];
     };
   };
   ```

---

## 3. Disk Partitioning & Formatting (Disko)

`disko.nix` declaratively provisions the drive with:
- **ESP Partition (1G):** FAT32 formatted for UEFI boot.
- **LUKS2 Swap Partition (17G):** encrypted swap; hibernation resumes from it. Size it to at least the machine's RAM.
- **LUKS2 Root Partition (rest):** Btrfs with subvolumes `root` (`/`), `nix` (`/nix`), and `home` (`/home`).

> ⚠️ **WARNING:** Disko is destructive and will erase all data on the target drive!

1. **Identify your disk identifier:**
   ```bash
   lsblk
   ```
   *Common targets: `/dev/nvme0n1` or `/dev/sda`.*

2. **Update `disko.nix` disk target:**
   Edit the `device` line in `disko.nix` to match your target drive path:
   ```nix
   main = {
     type = "disk";
     device = "/dev/nvme0n1"; # Adjust to /dev/sda or appropriate disk
   ```

3. **Execute Disko:**
   Run disko to partition, encrypt, format, and mount all subvolumes under `/mnt`:
   ```bash
   sudo nix --experimental-features "nix-command flakes" \
     run github:nix-community/disko/latest -- \
     --mode destroy,format,mount ./disko.nix
   ```
   *You will be prompted to enter and confirm your LUKS disk encryption passphrase.*

---

## 4. Generating Hardware Configuration

Now that the target filesystems are mounted at `/mnt`, generate the host-specific hardware configuration file.

1. **Generate hardware settings:**
   `disko.nix` is not imported by the system, so let it detect the mounts, LUKS devices, and swap from `/mnt`:
   ```bash
   sudo nixos-generate-config --root /mnt
   ```

2. **Copy generated hardware config to host folder:**
   - **For Freetop:**
     ```bash
     sudo cp /mnt/etc/nixos/hardware-configuration.nix ./hosts/Freetop/hardware-configuration.nix
     ```
   - **For Custom Host (e.g. MyLaptop):**
     ```bash
     sudo cp /mnt/etc/nixos/hardware-configuration.nix ./hosts/MyLaptop/hardware-configuration.nix
     ```

---

## 5. System Installation

1. **Copy Flake Repository to `/mnt/etc/nixos`:**
   ```bash
   sudo mkdir -p /mnt/etc/nixos
   sudo cp -r . /mnt/etc/nixos
   ```

2. **Execute `nixos-install`:**
   Run the installation referencing your target host (e.g., `Freetop` or `MyLaptop`):

   ```bash
   # For Freetop:
   sudo nixos-install --flake /mnt/etc/nixos#Freetop

   # For custom host:
   sudo nixos-install --flake /mnt/etc/nixos#MyLaptop
   ```

3. **Set Root Password:**
   When prompted at the end of the installation process, specify a root password.

4. **Reboot:**
   ```bash
   sudo reboot
   ```
   *Remove the USB flash drive when prompted.*

---

## 6. Post-Installation & Initial Setup

### 1. User Password & Login
Log into your system as user `mambuco` or `root` and set your user password:
```bash
sudo passwd mambuco
```

### 2. Enroll Secure Boot Keys (Lanzaboote)
The system uses Lanzaboote for UEFI Secure Boot signing.
1. Check Secure Boot status:
   ```bash
   sudo sbctl status
   ```
2. If setup mode is enabled in BIOS, create and enroll keys:
   ```bash
   sudo sbctl create-keys
   sudo sbctl enroll-keys
   ```
3. Re-verify enrollment and reboot to enforce Secure Boot:
   ```bash
   sudo sbctl verify
   ```

### 3. NextDNS Setup
If using NextDNS, open `modules/networking/default.nix` and replace the placeholder NextDNS endpoint profile ID with your custom profile identifier.

### 4. SSH Key Placement
Copy your private ED25519 SSH key to `~/.ssh/id_ed25519` and set secure file permissions:
```bash
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

### 5. Fingerprint Authentication Setup (Optional)
If your hardware supports fingerprint authentication (e.g., Elan 04f3:0c5e sensor):
```bash
fprintd-enroll
```

### 6. TPM2 Auto-Unlock of the Encrypted Disk (Optional)
With Secure Boot enforced, the TPM can unlock both LUKS volumes (`cryptroot` and `cryptswap`) at boot so no passphrase is needed. The key is sealed to **PCR 7** (Secure Boot state + enrolled keys): if Secure Boot gets disabled, the keys change, or someone boots an unsigned image, the TPM refuses and you are asked for the passphrase as usual.

> ⚠️ Do this **after** step 2. PCR 7 changes when Secure Boot keys are enrolled, so enrolling the TPM before that would seal to the wrong state.

1. **Check that a TPM2 chip is available:**
   ```bash
   systemd-cryptenroll --tpm2-device=list
   ```
   If nothing is listed, enable the TPM (often called *Intel PTT* or *Security Chip*) in the firmware setup.

2. **Tell the initrd to try the TPM.** The systemd initrd (`boot.initrd.systemd.enable` in `modules/boot`) already ships TPM2 support; each LUKS device just needs `tpm2-device=auto`. The device names are the UUID-based ones from the host's `hardware-configuration.nix`, so add this to `hosts/<host>/default.nix` (not to the regenerated hardware file):
   ```nix
   boot.initrd.luks.devices = {
     "luks-<root-uuid>".crypttabExtraOpts = [ "tpm2-device=auto" ];
     "luks-<swap-uuid>".crypttabExtraOpts = [ "tpm2-device=auto" ];
   };
   ```
   Optionally add `security.tpm2.enable = true;` to get `tpm2-tools` and the `tss` group in the running system. Then `sudo nixos-rebuild switch`.

3. **Find the LUKS partitions:**
   ```bash
   lsblk -o NAME,FSTYPE,UUID,MOUNTPOINTS
   ```
   The two `crypto_LUKS` partitions are the ones to enroll: the one holding `btrfs` is root, the one holding `swap` is swap. Their UUIDs are the same ones in the `luks-<uuid>` names of `hardware-configuration.nix`. Partition numbering differs between installs (disko puts swap on `p2`, the graphical installer may put it on `p3`), so the commands below use `/dev/disk/by-uuid/`.

4. **Enroll the TPM on both volumes** (you are asked for the existing passphrase each time):
   ```bash
   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/disk/by-uuid/<root-uuid>
   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/disk/by-uuid/<swap-uuid>
   ```
   Both must be enrolled: hibernation resumes from the encrypted swap, so the initrd has to unlock it too. Add `--tpm2-with-pin=yes` if you want a short PIN at boot instead of fully unattended unlock.

5. **Keep a fallback.** The original passphrase stays in its keyslot — don't remove it. Optionally also add a recovery key and store it offline (e.g. in Bitwarden):
   ```bash
   sudo systemd-cryptenroll --recovery-key /dev/disk/by-uuid/<root-uuid>
   ```

6. **Verify and reboot:**
   ```bash
   sudo systemd-cryptenroll /dev/disk/by-uuid/<root-uuid>   # lists keyslots; expect "password" and "tpm2"
   sudo reboot
   ```
   The system should go straight to GDM without the LUKS prompt.

**Re-enrolling:** firmware updates or changes to the Secure Boot keys (`sbctl enroll-keys`) alter PCR 7, and you'll get the passphrase prompt again. Unlock with the passphrase, then wipe and re-create the TPM slot on each volume:
```bash
sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=7 /dev/disk/by-uuid/<root-uuid>
sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=7 /dev/disk/by-uuid/<swap-uuid>
```

> **Security trade-off:** without a PIN, anyone holding the laptop can boot it to the login screen; disk confidentiality then rests on your user password and Secure Boot. Use `--tpm2-with-pin=yes` if that's not acceptable.

### 7. Remote Builder (Optional)
`modules/remote-builder` offloads builds to a more powerful machine over SSH, so packages that never come from cache.nixos.org (Lanzaboote, Aseprite, overridden or unfree packages) compile there instead of on the laptop. The builder can run any Linux distro with Nix installed; it does not need to be NixOS.

The repo only refers to the SSH alias `nix-builder`. The real hostname, user, key and host key live in root's SSH files, so they never get published. Until that alias resolves, Nix builds locally as usual, which means a fresh install works without any of this. To drop remote building entirely, remove `../../modules/remote-builder` from the host's imports.

1. **Install Nix on the builder** (multi-user), trust your account there, and let Nix clean up its store when the disk runs low:
   ```bash
   sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
   sudo tee -a /etc/nix/nix.conf <<'EOF'
   trusted-users = root <user>
   min-free = 20G
   max-free = 60G
   EOF
   sudo systemctl restart nix-daemon
   ```

2. **Create root's key and the `nix-builder` alias on the laptop.** The laptop's `nix-daemon` opens the connection as root, so these go in `/root/.ssh`:
   ```bash
   sudo ssh-keygen -t ed25519 -N "" -C freetop-nix-builder -f /root/.ssh/nix-builder
   sudo tee -a /root/.ssh/config <<'EOF'
   Host nix-builder
     HostName <builder-host>
     User <user>
     IdentityFile /root/.ssh/nix-builder
     IdentitiesOnly yes
     ConnectTimeout 5
     ServerAliveInterval 30
   EOF
   ssh-keyscan -t ed25519 <builder-host> | sudo tee -a /root/.ssh/known_hosts
   ```
   Check the scanned key against `ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub` run on the builder. `ConnectTimeout` makes builds fall back to local quickly when you're offline.

3. **Authorise the key on the builder.** The key is restricted so that it can only talk to the Nix daemon and can't open a shell:
   ```bash
   echo "restrict,command=\"/nix/var/nix/profiles/default/bin/nix-daemon --stdio\" $(sudo cat /root/.ssh/nix-builder.pub)" \
     | ssh <user>@<builder-host> 'cat >> ~/.ssh/authorized_keys'
   ```

4. **Test the connection:**
   ```bash
   sudo nix store info --store 'ssh-ng://nix-builder?remote-program=/nix/var/nix/profiles/default/bin/nix-daemon'
   ```

5. **First rebuild.** The builder entry only takes effect after a switch, so pass it on the command line once so that this rebuild is offloaded too:
   ```bash
   sudo nixos-rebuild switch \
     --option builders 'ssh-ng://nix-builder?remote-program=/nix/var/nix/profiles/default/bin/nix-daemon x86_64-linux - 4 10 big-parallel,benchmark' \
     --option builders-use-substitutes true
   ```
   After that, a plain `sudo nixos-rebuild switch` offloads automatically. Builds that ran remotely are logged as `building '…' on 'ssh-ng://nix-builder…'`. To check, run `nix build nixpkgs#hello --rebuild -L`.

**What it doesn't speed up:** vendor binaries such as Antigravity, Spotify and Chrome still download to the laptop. Only builds that actually compile benefit. The builder fetches its own dependencies from cache.nixos.org (`builders-use-substitutes`), so your upload link only carries the build results back.

---

## 7. Troubleshooting & Gotchas

- **File Collision ("Existing file would be clobbered"):**
  Home Manager is configured with `home-manager.backupFileExtension = "hm-backup"`. Conflicting user dotfiles will automatically be backed up with a `.hm-backup` suffix.

- **Insecure Electron Package Errors:**
  If Nix builds fail due to unmaintained Electron dependency pins (e.g., for Claude Desktop or Bitwarden), update `nixpkgs.config.permittedInsecurePackages` in [modules/nix/default.nix](file:///etc/nixos/modules/nix/default.nix).

- **Fish Shell Integrations Not Loaded:**
  On the first interactive login after adding new `programs.<x>.enable` options, execute `exec fish` or open a new terminal window to source freshly installed completion files.
