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

  # Default handlers, keyed by app .desktop id.
  clapper = "com.github.rafostar.Clapper.desktop";
  loupe = "org.gnome.Loupe.desktop";
  papers = "org.gnome.Papers.desktop";
  textEditor = "org.gnome.TextEditor.desktop";
  zed = "dev.zed.Zed.desktop";
  apostrophe = "org.gnome.gitlab.somas.Apostrophe.desktop";
  zen = "zen-beta.desktop";

  assign = app: mimes: map (m: lib.nameValuePair m app) mimes;

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

  audioMimes = [
    "audio/aac"
    "audio/flac"
    "audio/mp4"
    "audio/mpeg"
    "audio/ogg"
    "audio/opus"
    "audio/webm"
    "audio/x-vorbis+ogg"
    "audio/x-wav"
  ];

  imageMimes = [
    "image/avif"
    "image/bmp"
    "image/gif"
    "image/heif"
    "image/jpeg"
    "image/png"
    "image/svg+xml"
    "image/tiff"
    "image/webp"
    "image/x-icon"
  ];

  # Plain text plus structured config/data formats -> GNOME Text Editor.
  # (.nix, .ini, .conf carry no dedicated MIME and land here as text/plain.)
  textMimes = [
    "text/plain"
    "text/xml"
    "application/json"
    "application/toml"
    "application/xml"
    "application/x-yaml"
    "application/yaml"
  ];

  # Actual programming source -> Zed.
  codeMimes = [
    "application/javascript"
    "application/x-php"
    "application/x-ruby"
    "application/x-shellscript"
    "text/css"
    "text/javascript"
    "text/rust"
    "text/vnd.trolltech.linguist" # .ts collides with Qt Linguist in shared-mime-info
    "text/x-c++hdr"
    "text/x-c++src"
    "text/x-chdr"
    "text/x-csrc"
    "text/x-go"
    "text/x-java"
    "text/x-lua"
    "text/x-python"
    "text/x-rust"
    "text/x-shellscript"
  ];

  browserMimes = [
    "text/html"
    "application/xhtml+xml"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
    "x-scheme-handler/about"
    "x-scheme-handler/unknown"
  ];
in
{
  home.file = builtins.listToAttrs (map hideEntry hiddenApps);

  xdg.mimeApps = {
    enable = true;
    defaultApplications = builtins.listToAttrs (
      assign clapper videoMimes
      ++ assign clapper audioMimes
      ++ assign loupe imageMimes
      ++ assign papers [ "application/pdf" ]
      ++ assign textEditor textMimes
      ++ assign zed codeMimes
      ++ assign apostrophe [ "text/markdown" ]
      ++ assign zen browserMimes
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
