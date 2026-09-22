# Freetop — NixOS & Home Manager Flake

An opinionated, modular NixOS flake configuration managing **Freetop** (HP laptop, Intel CPU, GNOME on Wayland). Home Manager is integrated directly as a **NixOS module**, enabling unified system and user environment deployment through a single `nixos-rebuild` invocation.

---

## 🌟 System Overview

| Component | Specification |
| :--- | :--- |
| **OS / Branch** | NixOS `26.05` (Unstable / Rolling release track) |
| **Target Host** | `Freetop` (HP Laptop, Intel CPU, Elan Fingerprint Reader) |
| **Primary User** | `mambuco` |
| **Desktop Environment** | GNOME on Wayland with Catppuccin Macchiato styling |
| **Shell & Terminal** | Fish Shell + Starship Prompt |
| **Storage & Security** | LUKS2 Full Disk Encryption → Btrfs subvolumes |
| **Boot Mechanism** | UEFI `systemd-boot` + Lanzaboote (Secure Boot) |
| **Development & CLI** | `nix-ld`, Neovim, Zed, Docker/Podman, Antigravity CLI |

---

## 🏗️ Architecture & Directory Layout

The repository follows a strictly decoupled, concern-based module pattern. Every system module and user feature resides in its own self-contained directory containing a `default.nix`.

```
/etc/nixos/
├── flake.nix                  # Flake entrypoint & dependency declaration
├── flake.lock                 # Pinned flake lockfile
├── disko.nix                  # Declarative disk layout (LUKS2 + Btrfs + Swap)
├── INSTALL.md                 # Detailed step-by-step installation guide
├── hosts/
│   └── Freetop/               # Host-specific configuration & hardware pin
│       ├── default.nix        # Module imports, hostName, stateVersion
│       └── hardware-configuration.nix
├── modules/                   # System-level NixOS modules (one folder per concern)
│   ├── android/               # ADB & fastboot udev rules
│   ├── antigravity-flake-updates/ # Automated flake updating systemd timers
│   ├── audio/                 # PipeWire sound server & Bluetooth audio codecs
│   ├── avahi/                 # mDNS / DNS-SD local network resolution
│   ├── bluetooth/             # BlueZ stack & Blueman manager
│   ├── boot/                  # Lanzaboote Secure Boot & systemd-boot
│   ├── chromium-policies/    # Enterprise browser policies
│   ├── containers/            # Docker & Podman container runtimes
│   ├── desktop/               # GNOME Desktop, GDM display manager, Wayland
│   ├── fingerprint/           # Elan moc2 libfprint overlay & fprintd PAM setup
│   ├── fonts/                 # System font profiles (Noto, Fira Code, JetBrains Mono)
│   ├── hardware/              # TLP power management, thermald, Intel graphics
│   ├── hibernation/           # Swap offset & suspend/hibernate policies
│   ├── kdeconnect/            # GSConnect / KDE Connect desktop integration
│   ├── locale/                # Locale (en_GB), Timezone (Rome), Keyboard (IT)
│   ├── maintenance/           # Automatic Nix store optimization & garbage collection
│   ├── network-displays/      # Miracast / Wi-Fi Display support
│   ├── networking/            # NetworkManager, NextDNS resolver, OpenSSH
│   ├── nix/                   # Flake settings, unfree packages, insecurity overrides
│   ├── nix-ld/                # Dynamic loader shim for unpatched glibc binaries
│   ├── ollama/                # Local LLM runner daemon service
│   ├── oomd/                  # systemd-oomd low-memory management
│   ├── plymouth/              # Graphical boot splash theme
│   ├── shell/                 # System-wide shell initialization
│   ├── steam/                 # Steam gaming environment, Proton, 32-bit drivers
│   ├── syncthing/             # Continuous peer-to-peer file synchronization
│   ├── tailscale/             # Mesh VPN service daemon
│   ├── users/                 # System user accounts & privileges
│   └── xpad/                  # Linux kernel drivers for Xbox controllers
└── home/
    └── mambuco/               # User-level Home Manager modules
        ├── default.nix        # Main home aggregator module
        ├── budslink/          # Galaxy Buds control integration
        ├── chromium/          # Web browser configuration
        ├── cli/               # Modern CLI tools (btop, eza, bat, rg, fd, fzf, zoxide)
        ├── dev/               # Development toolchains & language environments
        ├── discord-rpc/       # Discord Rich Presence integration
        ├── fastfetch/         # System information fetch display tool
        ├── git/               # Git configuration, delta diff viewer, aliases
        ├── gnome/             # dconf settings, keybindings, extensions, app grid
        ├── helium/            # Helium browser module
        ├── neovim/            # Custom Neovim configuration (LSP, Treesitter, Telescope)
        ├── packages/          # GUI & CLI application suite (Bitwarden, Spotify, Claude, agy)
        ├── ssh/               # User SSH configuration
        ├── theme/             # GTK adw-gtk3, Catppuccin palette, Bibata cursors
        ├── vesktop/           # Custom Discord client wrapper
        ├── zed/               # Zed editor settings & extensions
        └── zen-browser/       # Zen Browser module with Catppuccin styling
```

---

## 📦 System & User Capabilities

### 🔧 Core System Services
- **Secure Boot & Bootloader:** `lanzaboote` replaces standard `systemd-boot` to enforce UEFI Secure Boot validation.
- **Networking & DNS:** NetworkManager paired with NextDNS encrypted DNS resolver (`DNSOverTLS`).
- **Power & Thermal Optimization:** Integrated `TLP` and `thermald` tuning for battery life and thermal control on HP Intel hardware.
- **Unpatched Binary Compatibility:** `programs.nix-ld` enables running dynamic glibc precompiled binaries (`~/.local/bin/` tools, standalone executables) without manual `patchelf`.
- **Custom Hardware Support:** `depau-libfprint` overlay adds driver support for Elan `04f3:0c5e` fingerprint sensors.

### 🎨 User Environment & Customizations
- **Integrated Home Manager:** Configured via `home-manager.nixosModules.home-manager` in `flake.nix`. Home configurations apply automatically during system rebuilds.
- **Theming System:** Catppuccin Macchiato color theme applied across GNOME, GTK apps (`adw-gtk3`), terminals, and web browsers via `catppuccin/nix`.
- **Shell Experience:** Interactive `fish` shell pre-configured with `starship` prompt, `zoxide` directory jump, `eza` file listings, `bat` syntax highlighting, `fzf`, `rg`, and `lazygit`.

---

## 🛠️ Operating & Maintaining the System

### Apply Configuration Changes
Rebuild and activate the system configuration:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#Freetop
```

### Update System & Application Flakes
Update all inputs in `flake.lock`:
```bash
nix flake update --flake /etc/nixos
```
*(Note: A background systemd timer in `modules/antigravity-flake-updates` automatically keeps fast-moving flake inputs updated).*

### Test Configuration Without Switching
Build the configuration and verify syntax before applying:
```bash
nixos-rebuild build --flake /etc/nixos#Freetop
```

---

## 🚀 Fresh Installation & Host Setup

For comprehensive step-by-step instructions on partitioning disks with `disko`, setting up LUKS encryption, configuring new host definitions, and performing a fresh system installation, refer to:

👉 **[INSTALL.md](./INSTALL.md)**

---

## 📜 License

Distributed under the [MIT License](./LICENSE).
