{ lib, pkgs, ... }:

let
  wallpaper = ../../home/mambuco/gnome/wallpaper.jpg;

  # The user-themes extension doesn't run in the greeter, so the login screen
  # gets the catppuccin stylesheet plus the desktop wallpaper behind the dialog.
  greeterStylesheet = pkgs.runCommand "gdm-catppuccin-stylesheet" { } ''
    mkdir -p $out
    cat ${pkgs.gnome-catppuccin-mocha}/share/themes/gnome-catppuccin/gnome-shell/gnome-shell.css - \
      > $out/gnome-shell-dark.css <<'EOF'

    #lockDialogGroup {
      background-color: #1e1e2e;
      background-image: url("file://${wallpaper}");
      background-size: cover;
      background-position: center;
    }
    EOF
    ln -s gnome-shell-dark.css $out/gnome-shell-light.css
  '';
in
{
  nixpkgs.overlays = [
    (final: prev: {
      gnome-catppuccin-mocha = final.callPackage ./package.nix { };
    })
  ];

  # gnome-shell loads its theme from a gresource at a compiled-in path, so the
  # only way in without rebuilding gnome-shell is a GLib resource overlay.
  # Scoped to the greeter instance; the user session keeps the user-themes path.
  # Raw unit rather than systemd.user.services, which would inject its own PATH.
  # Mutter finds cursors only via XCURSOR_PATH, which the greeter doesn't get.
  systemd.user.units."org.gnome.Shell@gdm.service" = {
    overrideStrategy = "asDropin";
    text = ''
      [Service]
      Environment="G_RESOURCE_OVERLAYS=/org/gnome/shell/theme=${greeterStylesheet}"
      Environment="XCURSOR_PATH=${pkgs.kdePackages.breeze}/share/icons:${pkgs.adwaita-icon-theme}/share/icons"
    '';
  };

  # mkBefore: earlier dconf databases win over gdm's own greeter defaults.
  programs.dconf.profiles.gdm.databases = lib.mkBefore [
    {
      settings."org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        accent-color = "blue";
        clock-format = "24h";
        clock-show-weekday = true;
        show-battery-percentage = true;
        cursor-theme = "breeze_cursors";
        cursor-size = lib.gvariant.mkInt32 24;
        font-name = "Geist 11";
        monospace-font-name = "Geist Mono 11";
      };
    }
  ];
}
