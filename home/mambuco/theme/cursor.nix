{ lib, pkgs, ... }:

{
  home.pointerCursor = {
    name = "breeze_cursors";
    package = pkgs.kdePackages.breeze;
    size = 24;
    gtk.enable = true;
    # gsd-xsettings owns the X cursor (theme + size via XSETTINGS) now that
    # XWayland is scaled — don't let the module write its own conflicting
    # Xresources/xsetroot state. See ../gnome for xwayland-scaling-factor.
    x11.enable = false;
  };

  # home.pointerCursor still exports XCURSOR_SIZE = size (24). XWayland runs at
  # xwayland-scaling-factor = 2, so a raw 24 would draw a 24 -> 12 logical ->
  # 15px pointer. Feed the pre-scaled 24 x 2 = 48 so X apps land at the same
  # 30 physical px (24 logical x 1.25) as the Wayland cursor. GNOME's Wayland
  # cursor ignores this var (it uses org.gnome.desktop.interface cursor-size).
  home.sessionVariables.XCURSOR_SIZE = lib.mkForce "48";
}
