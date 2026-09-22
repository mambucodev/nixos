---
name: flake-maintenance
description: >-
  Maintain flake inputs, handle package deprecations, manage permitted insecure packages,
  and update lockfiles cleanly without breaking dependencies.
---

# Flake Maintenance Runbook

Use this skill when updating flake inputs, managing Nixpkgs licenses or security exceptions, or resolving upstream deprecations.

---

## 1. Flake Inputs Guidelines

### Adding New Inputs
- Always add community flakes under `inputs = { ... };` in `flake.nix`.
- Add `inputs.nixpkgs.follows = "nixpkgs"` where applicable to avoid pulling redundant nixpkgs revisions into the store.
- If the flake is used in Home Manager modules, ensure `inputs` remains in `home-manager.extraSpecialArgs`.

### Updating Inputs
- Prefer targeted updates over blanket updates:
  ```bash
  nix flake update <input-name>
  ```
- After updating inputs, inspect the resulting `flake.lock` diff to verify that no unwanted transitive inputs were duplicated.

---

## 2. Insecure Packages & Deprecations

### Permitted Insecure Packages
- Packages relying on end-of-life runtimes (e.g. Electron versions pinned by desktop clients) are managed in:
  [`modules/nix/default.nix`](file:///etc/nixos/modules/nix/default.nix)
- Add or update version strings in `nixpkgs.config.permittedInsecurePackages`.

### Removed Namespaces & Options
- Do not use removed namespaces (e.g. `pkgs.nodePackages.*`). Tools like language servers live at top-level `pkgs.<name>`.
- Do not introduce backward-compatibility shims for removed NixOS options. Use modern option names directly.

---

## 3. Verification Rules

- **Pure evaluation check**:
  ```bash
  nix eval .#nixosConfigurations.Freetop.config.system.build.toplevel.drvPath
  ```
- **Staging**: Always stage modified `flake.nix`, `flake.lock`, or new modules with `git add`.
- **Rebuild**: Remind the user they can apply with:
  ```bash
  sudo nixos-rebuild switch
  ```
