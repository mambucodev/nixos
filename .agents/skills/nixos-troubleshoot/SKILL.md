---
name: nixos-troubleshoot
description: >-
  Investigate and fix issues on host Freetop that depend on or can be resolved by
  its NixOS and Home Manager configuration (systemd services, Wayland/GNOME, audio,
  networking, PAM, hardware, external binaries).
---

# NixOS Troubleshooting Runbook

Use this skill when diagnosing errors, misbehaving services, hardware integration problems, or app crashes on **Freetop**.

---

## 1. Safe Diagnostics (Non-Root)

Inspect runtime state and logs without modifying the running system or invoking `sudo`:

### User Services & Applications
- **Service status**: `systemctl --user status <service>`
- **Service logs**: `journalctl --user -u <service> -n 50 --no-pager`
- **Recent session errors**: `journalctl --user -b -p err --no-pager`
- **Socket availability**: Check `$XDG_RUNTIME_DIR/` (e.g., `cowork-vm-service.sock`, `discord-ipc-0`)

### Desktop & Wayland Inspection
- **Active Wayland app IDs / window classes**:
  Use `gdbus` or check running desktop files to ensure `StartupWMClass` matches GNOME launcher expectations (e.g., lowercase vs capitalized names).
- **dconf values**: `dconf read <path>` to check whether values applied as expected.

### External Binaries & Dynamic Linker
- If an external binary (e.g. `agy` in `~/.local/bin/`) fails with `No such file or directory`:
  Check `modules/nix-ld/default.nix`. Nix-ld provides standard glibc interpreter paths. Missing shared libraries should be added to `programs.nix-ld.libraries`.

---

## 2. Correlating to Repository Modules

Map root causes to the declarative NixOS module or Home Manager component:

| Symptom / Subsystem | Relevant Module | Common Root Causes |
| :--- | :--- | :--- |
| **Fingerprint reader / PAM** | `modules/fingerprint/` | elanmoc2 driver overlay; `fprintAuth` on GDM vs sudo conflicts |
| **Hibernation / Sleep** | `modules/hibernation/`, `hosts/Freetop/` | Resume offset mismatch, swap subvolume, systemd hibernation hooks |
| **Audio / Microphone** | `modules/audio/` | PipeWire / WirePlumber config, ALSA UCM profiles |
| **Networking / DNS** | `modules/networking/` | NextDNS CLI setup, NetworkManager DNS dispatchers |
| **Claude Cowork** | `modules/claude-cowork/` | Missing PATH entries in `services.claude-cowork.extraPath`, socket permissions |
| **Desktop / D-Bus / Tray** | `home/mambuco/gnome/` | Missing extensions, incorrect GVariant types in dconf, tray naming mismatches |
| **BudsLink / Bluetooth** | `home/mambuco/budslink/` | Companion service unit, BlueZ DBus bridge |

---

## 3. Formulating & Verifying the Declarative Fix

1. **Avoid imperative hacks**: Always implement the permanent fix in the relevant Nix module or Home Manager folder rather than editing mutable files in `/etc` or `~/.config` manually.
2. **Stage new files**: If creating a new helper or module, run `git add <file>`.
3. **Pure evaluation test**:
   ```bash
   nix eval .#nixosConfigurations.Freetop.config.system.build.toplevel.drvPath
   ```
4. **Handoff**: Never invoke `nixos-rebuild` or `sudo`. Instruct the user to apply:
   ```bash
   sudo nixos-rebuild switch
   ```
