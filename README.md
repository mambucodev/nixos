# freetop — NixOS configuration

A NixOS flake for a single host, **freetop** (HP laptop, Intel, GNOME on
Wayland). Home Manager is wired in as a NixOS module, so everything — system and
user — is applied by one `nixos-rebuild switch`.

- **NixOS:** 26.05
- **User:** mambuco
- **Desktop:** GNOME / Wayland, Catppuccin Macchiato
- **Shell:** fish + starship
- **Disk:** LUKS2 → btrfs subvolumes, Secure Boot via lanzaboote

## Layout

```
flake.nix                  entry point → nixosConfigurations.freetop
disko.nix                  declarative disk layout, for fresh installs only
hosts/freetop/             the only place that knows it's "freetop"
  default.nix              imports modules + hardware, sets hostName/stateVersion
  hardware-configuration.nix
modules/<name>/default.nix  one folder per system concern (boot, desktop, …)
home/mambuco/<name>/        one folder per user concern (cli, gnome, theme, …)
```

Every concern is its own folder with a `default.nix`. A folder gains extra files
only when a concern is big enough to section (e.g. `home/mambuco/theme/` splits
into `default.nix` + `gnome-catppuccin.nix` + `cursor.nix`; `home/mambuco/gnome/`
splits `default.nix` + `apps.nix`).

To add a concern: create `modules/<name>/default.nix` (or
`home/mambuco/<name>/default.nix`) and add it to the imports list in
`hosts/freetop/default.nix` (or `home/mambuco/default.nix`).

## Everyday use

```bash
sudo nixos-rebuild switch --flake /etc/nixos#freetop
```

Update inputs (Claude/Zed inputs also refresh weekly via a systemd timer):

```bash
nix flake update --flake /etc/nixos
```

## Installing on a new machine (disko)

`disko.nix` describes the whole disk declaratively — partitions, LUKS, the btrfs
subvolumes and the swapfile — so a reinstall is a couple of commands instead of
manual `fdisk`/`cryptsetup`/`mkfs`. It is **not** imported by the running system
(freetop already has its disks); it is only run by the `disko` tool at install
time. `⚠️ it erases the target disk.`

From the NixOS installer ISO:

```bash
# 0. get this repo (git clone … or copy it onto the installer)

# 1. point disko.nix at the target disk if it isn't /dev/nvme0n1
lsblk
$EDITOR disko.nix          # set disk.main.device

# 2. partition + format + mount everything under /mnt (prompts for the LUKS
#    passphrase). This is the destructive step.
sudo nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest -- \
  --mode destroy,format,mount ./disko.nix

# 3. generate hardware-configuration.nix for THIS machine (disko already made
#    the filesystems, so keep them out of the generated file)
sudo nixos-generate-config --no-filesystems --root /mnt

# 4. put the flake in place and install
sudo cp -r . /mnt/etc/nixos
sudo nixos-install --flake /mnt/etc/nixos#freetop

# 5. reboot; then enroll Secure Boot keys once (lanzaboote): `sudo sbctl enroll-keys`
```

What each disko mode does: `destroy` wipes existing partitions, `format` writes
the new partition table + filesystems, `mount` mounts them under `/mnt` ready for
`nixos-install`. Test changes to `disko.nix` in a VM before trusting them on real
hardware — it is destructive by design.

## Notes for anyone reusing this

- `modules/networking/` sets a personal **NextDNS** resolver hostname
  (`…dns.nextdns.io`) — replace it with your own profile or a public resolver.
- `hosts/freetop/hardware-configuration.nix` is machine-specific (disk UUIDs,
  kernel modules). Regenerate it on new hardware (step 3 above).
- SSH/vault secrets are **not** in this repo. The SSH key lives on disk
  (`~/.ssh/id_ed25519`, created manually) and is protected at rest by LUKS.

## License

MIT — see [LICENSE](./LICENSE).
