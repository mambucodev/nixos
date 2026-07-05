# Repository overview

This is a NixOS flake configuring a single host, **freetop** (HP laptop, Intel CPU, GNOME on Wayland, fish + starship). Single user: **mambuco**. NixOS 26.05.

Home Manager is wired as a **NixOS module** (not standalone) — there is no `home-manager` CLI; everything goes through `nixos-rebuild switch`.

# Directory layout

Every concern is its own **folder** with a `default.nix`. A folder gains extra
files only when it needs sectioning (see `home/mambuco/theme/` and `.../gnome/`).

```
flake.nix                    entry point; defines nixosConfigurations.freetop
flake.lock
disko.nix                    declarative disk layout; FRESH INSTALLS ONLY,
                             not imported by the running system
README.md / LICENSE / .gitignore
hosts/freetop/
  default.nix                only file that knows it is "freetop";
                             imports hardware + modules, sets hostName + stateVersion
  hardware-configuration.nix
modules/<name>/default.nix   one folder per system-level concern, e.g.
  boot/                      lanzaboote + UEFI
  networking/                NetworkManager + NextDNS + openssh
  locale/                    IT keyboard, en_GB locale, Rome TZ
  desktop/                   xserver + gdm + gnome + printing + libinput
  nix/                       experimental-features, allowUnfree, permittedInsecurePackages
  fingerprint/               libfprint elanmoc2 overlay + fprintd + PAM
  claude/                    /root theme mirror (+ themes/ asset)
  …                          (audio, shell, users, hibernation, steam, …)
home/mambuco/<name>/         one folder per user-level concern
  default.nix                aggregator; imports the rest; sets username + stateVersion
  packages/                  GUI apps via home.packages (bitwarden, claude-desktop, cider, …)
  cli/                       programs.<x>.enable for btop/eza/bat/rg/fd/fzf/zoxide/lazygit/gh
  git/                       programs.git with delta + aliases + ignores
  zen-browser/               zen module + policies (+ catppuccin/ CSS assets)
  gnome/                     default.nix = dconf.settings; apps.nix = mimeapps/autostart/hidden
  neovim/                    programs.neovim with LSP, treesitter, telescope, cmp
  theme/                     default.nix + gnome-catppuccin.nix + cursor.nix
  claude/                    programs.claude-code + Claude Desktop theme asset
```

# Conventions and patterns

- **One folder per concern.** New shared concern → new `modules/<name>/default.nix`, then add `../../modules/<name>` to `hosts/freetop/default.nix` imports. New user-side concern → new `home/mambuco/<name>/default.nix`, then add `./<name>` to `home/mambuco/default.nix` imports. Split a folder into multiple files only when the concern is big enough to section.
- **Module shape is the standard NixOS form** — `{ config, lib, pkgs, ... }: { ... }`. Args you don't use can stay as `{ ... }:`.
- **`inputs` is forwarded** via `specialArgs` (system) and `extraSpecialArgs` (home-manager). Any module that needs an input takes `{ inputs, ... }:` at the top.
- **Modules don't know what host they're on.** Only `hosts/freetop/default.nix` sets `networking.hostName` and `system.stateVersion`. A second host would be a sibling directory.
- **Prefer `programs.<x>.enable` over raw packages** when home-manager has a module — the module wires shell/git integrations and config files. Add to `home.packages` only when no module exists or you only need the binary.
- **For new programs that have a catppuccin/nix port**, enabling the program is enough — `catppuccin.autoEnable = true` is set globally, so the theme attaches automatically.
- **GNOME tweaks all live in `home/mambuco/gnome/default.nix`** under `dconf.settings` (app-grid/mimetype/autostart tweaks are in the sibling `apps.nix`). Use `lib.hm.gvariant.mkUint32` (etc.) for typed values.

# Workflow

- **Apply changes:** `nixos-rebuild switch`. From inside `/etc/nixos` is fine; the flake is at `/etc/nixos/flake.nix`.
- **Long builds (first time installing claude-desktop, bitwarden, big neovim plugin sets):** run with `&` or `run_in_background` from the agent — multiple minutes is normal.
- **First-time fish integration:** when adding any new `programs.<x>.enable` that emits fish init, the user must open a new shell (or `exec fish`) to see it.
- **dconf changes:** apply immediately for keybindings; visual changes (accent color, GTK theme) need a GNOME logout/login.
- **Conflict like "Existing file would be clobbered":** `home-manager.backupFileExtension = "hm-backup"` is set in `flake.nix`. Backups land next to the original with that suffix.

# Important gotchas

- **`inputs` infinite recursion**: if a home-manager file imports something from `inputs.*`, `inputs` MUST be in `extraSpecialArgs`. It is. Don't remove that line from `flake.nix`.
- **`nodePackages` namespace was removed** in this nixpkgs revision. TypeScript LSP etc. live at the top level (`pkgs.typescript-language-server`).
- **catppuccin/nix has no GTK theme module** — only icons (`catppuccin.gtk.icon`) and cursors. GTK theme is `adw-gtk3` from nixpkgs, wired manually in `home/mambuco/theme/default.nix`.
- **catppuccin/nix has no Ptyxis or GNOME Shell module.** Don't waste time looking. To theme Ptyxis tabs you'd need a custom palette in `org.gnome.Ptyxis.custom-palettes` via dconf.
- **Electron in nixpkgs gets marked insecure routinely.** `nixpkgs.config.permittedInsecurePackages` in `modules/nix/default.nix` already lists the version Claude Desktop depends on. If the upstream pin moves, update the version string there.
- **fprintd on GDM**: `security.pam.services.login.fprintAuth` is set to `false` by the GDM module deliberately. Don't try to set it to `true` — it will conflict. Use `gdm-password` for graphical login and `sudo` for terminal.
- **Claude Cowork service** runs as `systemd.user.service` `claude-cowork.service`. Socket: `$XDG_RUNTIME_DIR/cowork-vm-service.sock`. The PATH needs `claude` (the claude-code CLI) → currently passed via `services.claude-cowork.extraPath`.

# Adding things — quick patterns

- **A new GUI app for mambuco**: add to the list in `home/mambuco/packages/default.nix`. If it has a `programs.<x>` module, add to `home/mambuco/cli/default.nix` or a new folder instead.
- **A new system service**: new `modules/<name>/default.nix`, add `../../modules/<name>` to `hosts/freetop/default.nix` imports.
- **A new flake input** (e.g. another community flake): add under `inputs = { ... };` in `flake.nix` with `inputs.nixpkgs.follows = "nixpkgs"` to avoid duplicate nixpkgs.
- **A new host**: `hosts/<name>/default.nix` + its own `hardware-configuration.nix`, then add `nixosConfigurations.<name> = nixpkgs.lib.nixosSystem { ... }` in `flake.nix`. Pick which `modules/<name>` apply.
- **Reinstalling / new disk**: `disko.nix` reproduces the LUKS + btrfs-subvolume layout. It is not imported by the running system — see README.md for the install flow.
- **A new user**: mirror `home/mambuco/`; add another `home-manager.users.<name> = import ./home/<name>;` line in the flake.

# Style for AI agents working here

- Keep changes minimal — don't refactor neighboring code when adding a thing.
- Don't write comments unless explaining a non-obvious *why*. The patterns above are the convention; the code reads itself.
- Don't add backup-compatibility shims for replaced/removed options.
- For long builds, run in background and report back. Don't sit waiting.
