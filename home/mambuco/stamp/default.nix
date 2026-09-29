{ pkgs, ... }:

let
  stamp = pkgs.stdenv.mkDerivation {
    pname = "stamp";
    version = "0.4.0-unstable-2026-09-12";

    src = pkgs.fetchFromGitLab {
      domain = "gitlab.gnome.org";
      owner = "jbrummer";
      repo = "stamp";
      rev = "0ea93b7bce71a586274a835ffeae69ebc014641b";
      hash = "sha256-GSAYL5nw3oaHHtNX/EOOD1lkKxOPuSzlo9uaVrDupNk=";
    };

    nativeBuildInputs = with pkgs; [
      meson
      ninja
      pkg-config
      blueprint-compiler
      desktop-file-utils
      gettext
      glib
      wrapGAppsHook4
    ];

    buildInputs = with pkgs; [
      gtk4
      libadwaita
      evolution-data-server
      evolution-data-server-gtk4
      gsettings-desktop-schemas
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      libsoup_3
      libportal-gtk4
      libpsl
      nss
      gpgme
      webkitgtk_6_0
      gdk-pixbuf
    ];

    meta = with pkgs.lib; {
      description = "Fast, native email and PIM client for GNOME built with GTK4 and Libadwaita";
      homepage = "https://gitlab.gnome.org/jbrummer/stamp";
      license = licenses.gpl3Plus;
      platforms = platforms.linux;
      mainProgram = "stamp";
    };
  };
in
{
  home.packages = [
    stamp
  ];
}
