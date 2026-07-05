{ lib, ... }:

let
  inherit (lib.hm.gvariant) mkUint32;
in
{
  imports = [ ./apps.nix ];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      accent-color = "blue";
      clock-format = "24h";
      clock-show-weekday = true;
      clock-show-seconds = false;
      show-battery-percentage = true;
      enable-animations = true;
      enable-hot-corners = false;
      cursor-theme = "breeze_cursors";
    };

    "org/gnome/desktop/background" = {
      picture-uri = "file:///home/mambuco/Pictures/Wallpapers/nix-black-4k.png";
      picture-uri-dark = "file:///home/mambuco/Pictures/Wallpapers/nix-black-4k.png";
      picture-options = "zoom";
    };

    "org/gnome/desktop/screensaver" = {
      picture-uri = "file:///home/mambuco/Pictures/Wallpapers/nix-black-4k.png";
      picture-options = "zoom";
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      natural-scroll = true;
      two-finger-scrolling-enabled = true;
      disable-while-typing = true;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
      focus-mode = "click";
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = true;
      edge-tiling = true;
      workspaces-only-on-primary = false;
      center-new-windows = true;
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 300;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-battery-type = "suspend";
      sleep-inactive-battery-timeout = 900;
      power-button-action = "interactive";
    };

    "org/gnome/desktop/notifications" = {
      show-in-lock-screen = false;
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
      show-hidden-files = false;
      show-create-link = true;
    };

    "org/gnome/nautilus/list-view" = {
      default-zoom-level = "small";
    };

    "org/gtk/settings/file-chooser" = {
      sort-directories-first = true;
      show-hidden = false;
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      home = [ "<Super>e" ];
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>t";
      command = "ghostty";
      name = "Open Ghostty";
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      # hibernate-status@dromi only declares GNOME ≤48; force-load it on 50.
      disable-extension-version-validation = true;
      enabled-extensions = [
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "BudsLink-Companion@maniacx.github.com"
        "hibernate-status@dromi"
        "gsconnect@andyholmes.github.io"
        "appindicatorsupport@rgcjonas.gmail.com"
        "mediacontrols@cliffniff.github.com"
        "top-bar-organizer@julian.gse.jsts.xyz"
      ];
      favorite-apps = [
        "com.mitchellh.ghostty.desktop"
        "zen-beta.desktop"
        "org.gnome.Nautilus.desktop"
        "vesktop.desktop"
        "claude.desktop"
      ];
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "gnome-catppuccin";
    };

    "org/gnome/shell/extensions/mediacontrols" = {
      extension-position = "Left";
      extension-index = mkUint32 0;
      label-width = mkUint32 160;
      fixed-label-width = false;
    };

    "org/gnome/shell/extensions/top-bar-organizer" = {
      left-box-order = [ "activities" "Media Controls" "BudsLink-Companion@maniacx.github.com" ];
      center-box-order = [ "dateMenu" ];
      right-box-order = [
        "appindicator-kstatusnotifieritem-Cider_status_icon_1"
        "appindicator-kstatusnotifieritem-Claude_status_icon_1"
        "appindicator-kstatusnotifieritem-teams-for-linux_status_icon_1"
        "appindicator-kstatusnotifieritem-chrome_status_icon_1"
        "screenRecording"
        "screenSharing"
        "dwellClick"
        "a11y"
        "keyboard"
        "quickSettings"
      ];
    };
  };
}
