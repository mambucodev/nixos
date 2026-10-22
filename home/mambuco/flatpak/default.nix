{ config, ... }:

let
  iconTheme = config.gtk.iconTheme.package;
in
{
  # Home Manager files are symlinks into /nix/store, so the sandbox needs the
  # store to resolve gtk.css, settings.ini and the linked icon/cursor themes.
  xdg.dataFile."flatpak/overrides/global".text = ''
    [Context]
    filesystems=/nix/store:ro;xdg-config/gtk-3.0:ro;xdg-config/gtk-4.0:ro;xdg-data/icons:ro;~/.icons:ro
  '';

  # Flatpak can't see the Nix profile, so expose the icon theme where it looks.
  xdg.dataFile."icons/Papirus".source = "${iconTheme}/share/icons/Papirus";
  xdg.dataFile."icons/Papirus-Dark".source = "${iconTheme}/share/icons/Papirus-Dark";
}
