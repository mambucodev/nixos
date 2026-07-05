{ lib, ... }:

let
  # Hide app-grid entries by shadowing the system .desktop with a NoDisplay stub
  # under ~/.local/share/applications (still runnable directly).
  hiddenApps = [
    # GTK/KDE demos and config tools
    "gtk3-demo"
    "gtk3-icon-browser"
    "gtk3-widget-factory"
    "kbd-layout-viewer5"
    "breezestyleconfig"
    "kcm_breezedecoration"

    # CLI/TUI binaries that ship a desktop entry
    "xterm"
    "nvim"
    "btop"
    "scrcpy-console"

    # Background services / one-shot helpers
    "rygel"
    "rygel-preferences"
    "gcm-import"
    "gcm-picker"
    "gnome-system-monitor-kde"
    "gnome-initial-setup"
  ];

  hideEntry = name: {
    name = ".local/share/applications/${name}.desktop";
    value.text = ''
      [Desktop Entry]
      Type=Application
      Name=${name}
      NoDisplay=true
      Exec=true
    '';
  };

  # Clapper as default handler for every video type it advertises.
  clapper = "com.github.rafostar.Clapper.desktop";
  videoMimes = [
    "video/3gp"
    "video/3gpp"
    "video/3gpp2"
    "video/divx"
    "video/dv"
    "video/fli"
    "video/flv"
    "video/mp2t"
    "video/mp4"
    "video/mp4v-es"
    "video/mpeg"
    "video/mpeg-system"
    "video/msvideo"
    "video/ogg"
    "video/quicktime"
    "video/vnd.mpegurl"
    "video/vnd.rn-realvideo"
    "video/webm"
    "video/x-avi"
    "video/x-flc"
    "video/x-fli"
    "video/x-flv"
    "video/x-m4v"
    "video/x-matroska"
    "video/x-mpeg"
    "video/x-mpeg-system"
    "video/x-mpeg2"
    "video/x-ms-asf"
    "video/x-ms-wm"
    "video/x-ms-wmv"
    "video/x-ms-wmx"
    "video/x-msvideo"
    "video/x-nsv"
    "video/x-ogm+ogg"
    "video/x-theora"
    "video/x-theora+ogg"
  ];
in
{
  home.file = builtins.listToAttrs (map hideEntry hiddenApps);

  xdg.mimeApps = {
    enable = true;
    defaultApplications = builtins.listToAttrs (
      map (m: lib.nameValuePair m clapper) videoMimes
    );
  };

  # Start these minimized into the tray at login (flags are the apps' own).
  xdg.configFile = {
    "autostart/vesktop.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Vesktop
      Exec=vesktop --start-minimized
      StartupNotify=false
      Terminal=false
      Icon=vesktop
      X-GNOME-Autostart-enabled=true
    '';

    "autostart/bitwarden.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Bitwarden
      Exec=bitwarden --hidden
      StartupNotify=false
      Terminal=false
      Icon=bitwarden
      X-GNOME-Autostart-enabled=true
    '';

    "autostart/teams-for-linux.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Microsoft Teams for Linux
      Exec=teams-for-linux --minimized
      StartupNotify=false
      Terminal=false
      Icon=teams-for-linux
      X-GNOME-Autostart-enabled=true
    '';
  };
}
