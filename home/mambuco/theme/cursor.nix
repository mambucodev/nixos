{ pkgs, ... }:

{
  home.pointerCursor = {
    name = "breeze_cursors";
    package = pkgs.kdePackages.breeze;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # eDP-1 runs at 1.25 scale but Mutter doesn't scale the XWayland cursor, so X11
  # apps draw a shrunken 24px pointer. Re-assert a pre-scaled 30px (24 × 1.25)
  # into the session env after login. Bump if the primary scale changes.
  systemd.user.services.xwayland-cursor-size = {
    Unit = {
      Description = "Enlarge XWayland cursor to match the fractionally-scaled Wayland cursor";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd XCURSOR_SIZE=30";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
