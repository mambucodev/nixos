---
name: manage-packages
description: >-
  Add, change, fix, replace, or remove software and packages in this NixOS flake.
  Provides concise curation of options for new apps and enforces repository layout conventions.
---

# Package Management Runbook

Use this skill whenever adding, replacing, updating, or removing software on host **Freetop**.

---

## 1. Option Curation (When Adding or Switching Apps)

When the user requests an app or a replacement:
1. **Research options**: Check Nixpkgs, community flakes (e.g., `spicetify-nix`, `zen-browser-flake`), and specialized wrappers.
2. **Present concise options**: Provide a short, structured comparison to help the user pick fast:
   - Official package vs. community wrapper / flake vs. lightweight / TUI alternative.
   - Theme compatibility (e.g. Catppuccin Macchiato alignment).
   - Any trade-offs (e.g. unfree license, Electron overhead, feature limits).
3. Wait for the user's choice before making changes.

---

## 2. Implementation Conventions

Follow the repository rules in `GEMINI.md`:

### Concern Placement
- **One folder per concern**:
  - User concern: `home/mambuco/<name>/default.nix`, imported in `home/mambuco/default.nix`.
  - System concern: `modules/<name>/default.nix`, imported in `hosts/Freetop/default.nix`.
- **Module vs. raw package**:
  - Prefer `programs.<x>.enable` when a Home Manager or NixOS module exists.
  - Use `home.packages = [ pkgs.<x> ]` in `home/mambuco/packages/default.nix` only when no module exists.

### Desktop & Theme Integration Checklist
- **Catppuccin theming**: `catppuccin.autoEnable = true` is set globally in `home/mambuco/theme/default.nix`. Most supported programs theme automatically. For unsupported apps, inspect if custom CSS/ini or a companion flake is needed.
- **Dock (Dash to Dock)**: If the app should be pinned or unpinned, update `favorite-apps` in `home/mambuco/gnome/default.nix` using the exact `.desktop` file name.
- **Top Bar Tray**: If replacing an app with an appindicator (status icon), clean up or add its ID in `top-bar-organizer` `right-box-order` in `home/mambuco/gnome/default.nix`.
- **Media players**: Check `home/mambuco/discord-rpc/default.nix` if Discord Rich Presence bridging is needed.

---

## 3. Verification & Execution Rules

- **NEVER run `nixos-rebuild`**: Do not invoke `switch`, `boot`, `test`, or `build`.
- **NEVER run `sudo`**: Agents must never invoke `sudo`.
- **Always stage new files**: Run `git add <path>` so Nix Flakes can see newly created files.
- **Safe verification**: Test evaluation without building or mutating state:
  ```bash
  nix eval .#nixosConfigurations.Freetop.config.system.build.toplevel.drvPath
  ```
- **Handoff to user**: Tell the user they can rebuild with:
  ```bash
  sudo nixos-rebuild switch
  ```
