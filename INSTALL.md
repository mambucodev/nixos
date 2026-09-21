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
       ../../modules/zed-overlay
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
- **ESP Partition (512M):** FAT32 formatted for UEFI boot.
- **LUKS2 Partition:** AES-256 encrypted container.
- **Btrfs Subvolumes inside LUKS:** `@root` (`/`), `@home` (`/home`), `@nix` (`/nix`), `@log` (`/var/log`), and `@swap` (swapfile).

> ⚠️ **WARNING:** Disko is destructive and will erase all data on the target drive!

1. **Identify your disk identifier:**
   ```bash
   lsblk
   ```
   *Common targets: `/dev/nvme0n1` or `/dev/sda`.*

2. **Update `disko.nix` disk target:**
   Edit line 7 of `disko.nix` to match your target drive path:
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
   Use `--no-filesystems` so filesystem mounts remain managed by `disko`:
   ```bash
   sudo nixos-generate-config --no-filesystems --root /mnt
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

---

## 7. Troubleshooting & Gotchas

- **File Collision ("Existing file would be clobbered"):**
  Home Manager is configured with `home-manager.backupFileExtension = "hm-backup"`. Conflicting user dotfiles will automatically be backed up with a `.hm-backup` suffix.

- **Insecure Electron Package Errors:**
  If Nix builds fail due to unmaintained Electron dependency pins (e.g., for Claude Desktop or Bitwarden), update `nixpkgs.config.permittedInsecurePackages` in [modules/nix/default.nix](file:///etc/nixos/modules/nix/default.nix).

- **Fish Shell Integrations Not Loaded:**
  On the first interactive login after adding new `programs.<x>.enable` options, execute `exec fish` or open a new terminal window to source freshly installed completion files.
