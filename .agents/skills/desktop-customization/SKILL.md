---
name: desktop-customization
description: >-
  Configure desktop UI, dock, top bar, keybindings, extensions, GTK themes, and dconf
  settings in Home Manager without syntax or GVariant type errors.
---

# Desktop Customization Runbook

Use this skill when modifying desktop styling, docks, panels, keybindings, application launchers, or theme settings.

---

## 1. File Organization

All desktop customizations reside under `home/mambuco/`:
- **`gnome/default.nix`**: `dconf.settings` (Dash to Dock, Top Bar Organizer, keybindings, extension configs).
- **`gnome/apps.nix`**: MIME associations (`xdg.mimeApps`), autostart entries, and hidden desktop items.
- **`theme/default.nix`**: Catppuccin Macchiato palette, GTK 3/4 CSS overrides (`@define-color`), icons, and adw-gtk3 theme.
- **`theme/gnome-catppuccin.nix`**: Custom Catppuccin GNOME Shell user theme.

---

## 2. dconf & GVariant Rules

Home Manager configures `dconf` declaratively. Follow these rules to avoid evaluation or runtime errors:

### GVariant Value Types
- **Integers**: GNOME schemas expect unsigned 32-bit integers for widths, positions, and timers. Always use:
  ```nix
  lib.hm.gvariant.mkUint32 160
  ```
- **Strings, Booleans, Lists**: Standard Nix strings, booleans, and lists of strings map naturally:
  ```nix
  dock-position = "BOTTOM";
  custom-background-color = true;
  favorite-apps = [ "zen.desktop" "spotify.desktop" ];
  ```

### Dock (Dash to Dock)
- Pinned applications live in `org/gnome/shell` under `favorite-apps`.
- Always check the exact `.desktop` filename produced by the package (located in `<pkg>/share/applications/`).

### Top Bar Organizer
- Items in `left-box-order`, `center-box-order`, and `right-box-order` must match extension titles or AppIndicator IDs:
  ```nix
  "appindicator-kstatusnotifieritem-<App>_status_icon_1"
  ```
- When removing an application with a tray icon, remove its entry from `right-box-order` to prevent phantom spacing.

### Custom Keybindings
- Must be registered in `org/gnome/settings-daemon/plugins/media-keys.custom-keybindings` as a list of paths:
  ```nix
  custom-keybindings = [
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
  ];
  ```
- Then define each path with `name`, `command`, and `binding`.

---

## 3. Verification & Application

1. Verify purely:
   ```bash
   nix eval .#nixosConfigurations.Freetop.config.system.build.toplevel.drvPath
   ```
2. User handoff:
   - Run `sudo nixos-rebuild switch`.
   - Keybindings and dock settings take effect immediately.
   - Theme and Shell CSS changes require logging out and back in to GNOME.
