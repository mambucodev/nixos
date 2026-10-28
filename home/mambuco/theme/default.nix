{ inputs, pkgs, ... }:

let
  # Libadwaita ignores GTK themes, so override its named colors directly.
  # adw-gtk3 reads the same names, so one block covers GTK3 and GTK4.
  catppuccinNamedColors = ''
    @define-color accent_color #89b4fa;
    @define-color accent_bg_color #89b4fa;
    @define-color accent_fg_color #11111b;

    @define-color destructive_color #f38ba8;
    @define-color destructive_bg_color #f38ba8;
    @define-color destructive_fg_color #11111b;

    @define-color success_color #a6e3a1;
    @define-color success_bg_color #a6e3a1;
    @define-color success_fg_color #11111b;

    @define-color warning_color #f9e2af;
    @define-color warning_bg_color #f9e2af;
    @define-color warning_fg_color #11111b;

    @define-color error_color #f38ba8;
    @define-color error_bg_color #f38ba8;
    @define-color error_fg_color #11111b;

    @define-color window_bg_color #1e1e2e;
    @define-color window_fg_color #cdd6f4;

    @define-color view_bg_color #1e1e2e;
    @define-color view_fg_color #cdd6f4;

    @define-color headerbar_bg_color #181825;
    @define-color headerbar_fg_color #cdd6f4;
    @define-color headerbar_border_color #cdd6f4;
    @define-color headerbar_backdrop_color @window_bg_color;
    @define-color headerbar_shade_color rgba(0, 0, 0, 0.36);

    @define-color card_bg_color #313244;
    @define-color card_fg_color #cdd6f4;
    @define-color card_shade_color rgba(0, 0, 0, 0.36);

    @define-color dialog_bg_color #313244;
    @define-color dialog_fg_color #cdd6f4;

    @define-color popover_bg_color #313244;
    @define-color popover_fg_color #cdd6f4;

    @define-color sidebar_bg_color #181825;
    @define-color sidebar_fg_color #cdd6f4;
    @define-color sidebar_backdrop_color #11111b;
    @define-color sidebar_shade_color rgba(0, 0, 0, 0.25);
    @define-color sidebar_border_color #11111b;

    /* Inner pane of a nested AdwNavigationSplitView (Newsflash's article list). */
    @define-color secondary_sidebar_bg_color #181825;
    @define-color secondary_sidebar_fg_color #cdd6f4;
    @define-color secondary_sidebar_backdrop_color #11111b;
    @define-color secondary_sidebar_shade_color rgba(0, 0, 0, 0.25);
    @define-color secondary_sidebar_border_color #11111b;

    @define-color thumbnail_bg_color #313244;
    @define-color thumbnail_fg_color #cdd6f4;
  '';
in
{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
    ./gnome-catppuccin.nix
    ./cursor.nix
    ./text-editor.nix
  ];

  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
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
