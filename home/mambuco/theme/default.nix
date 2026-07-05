{ inputs, pkgs, ... }:

let
  # Libadwaita ignores GTK themes, so override its named colors directly.
  # adw-gtk3 reads the same names, so one block covers GTK3 and GTK4.
  catppuccinNamedColors = ''
    @define-color accent_color #8aadf4;
    @define-color accent_bg_color #8aadf4;
    @define-color accent_fg_color #181926;

    @define-color destructive_color #ed8796;
    @define-color destructive_bg_color #ed8796;
    @define-color destructive_fg_color #181926;

    @define-color success_color #a6da95;
    @define-color success_bg_color #a6da95;
    @define-color success_fg_color #181926;

    @define-color warning_color #eed49f;
    @define-color warning_bg_color #eed49f;
    @define-color warning_fg_color #181926;

    @define-color error_color #ed8796;
    @define-color error_bg_color #ed8796;
    @define-color error_fg_color #181926;

    @define-color window_bg_color #24273a;
    @define-color window_fg_color #cad3f5;

    @define-color view_bg_color #24273a;
    @define-color view_fg_color #cad3f5;

    @define-color headerbar_bg_color #1e2030;
    @define-color headerbar_fg_color #cad3f5;
    @define-color headerbar_border_color #cad3f5;
    @define-color headerbar_backdrop_color @window_bg_color;
    @define-color headerbar_shade_color rgba(0, 0, 0, 0.36);

    @define-color card_bg_color #363a4f;
    @define-color card_fg_color #cad3f5;
    @define-color card_shade_color rgba(0, 0, 0, 0.36);

    @define-color dialog_bg_color #363a4f;
    @define-color dialog_fg_color #cad3f5;

    @define-color popover_bg_color #363a4f;
    @define-color popover_fg_color #cad3f5;

    @define-color sidebar_bg_color #1e2030;
    @define-color sidebar_fg_color #cad3f5;
    @define-color sidebar_backdrop_color #181926;
    @define-color sidebar_shade_color rgba(0, 0, 0, 0.25);

    @define-color thumbnail_bg_color #363a4f;
    @define-color thumbnail_fg_color #cad3f5;
  '';
in
{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
    ./gnome-catppuccin.nix
    ./cursor.nix
  ];

  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "macchiato";
    accent = "blue";

    gtk.icon.enable = true;
    cursors.enable = false;
    vesktop.enable = true;
  };

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
  };

  dconf.settings."org/gnome/desktop/interface".gtk-theme = "adw-gtk3-dark";

  xdg.configFile."gtk-3.0/gtk.css".text = catppuccinNamedColors;
  xdg.configFile."gtk-4.0/gtk.css".text = catppuccinNamedColors;
}
