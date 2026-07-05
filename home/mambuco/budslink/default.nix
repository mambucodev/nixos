{ pkgs, ... }:

let
  budslink = pkgs.stdenv.mkDerivation rec {
    pname = "budslink";
    version = "0.1.5";

    src = pkgs.fetchFromGitHub {
      owner = "maniacx";
      repo = "BudsLink";
      rev = "v${version}";
      sha256 = "054w9jwxfp1r7vyzi2qz9z2kv60n1c68i2vfjm5j50ngcsx0avkp";
    };

    nativeBuildInputs = with pkgs; [
      meson
      ninja
      pkg-config
      gettext
      glib
      gobject-introspection
      wrapGAppsHook4
      desktop-file-utils
    ];

    buildInputs = with pkgs; [
      gjs
      gtk4
      libadwaita
      bluez
      libpulseaudio
    ];

    meta = with pkgs.lib; {
      description = "Battery status and ANC control for several Bluetooth earbuds";
      homepage = "https://github.com/maniacx/BudsLink";
      license = licenses.gpl3Plus;
      platforms = platforms.linux;
      mainProgram = "budslink";
    };
  };

  budslink-companion-uuid = "BudsLink-Companion@maniacx.github.com";

  budslink-companion = pkgs.stdenv.mkDerivation {
    pname = "gnome-shell-extension-budslink-companion";
    version = "1-unstable-2026-06-21";

    src = pkgs.fetchFromGitHub {
      owner = "maniacx";
      repo = "BudsLink-Companion";
      rev = "40c6f4c2e64ecc8b2037d33f2bc9751d797a7b12";
      sha256 = "1f6m0wp9cyksnx7lmfh83bb4r69kjn65pzdsirb097gxmk3h99d0";
    };

    nativeBuildInputs = with pkgs; [ glib gettext ];

    buildPhase = ''
      runHook preBuild
      glib-compile-schemas schemas/
      for po in po/*.po; do
        lang=$(basename "$po" .po)
        mkdir -p "locale/$lang/LC_MESSAGES"
        msgfmt "$po" -o "locale/$lang/LC_MESSAGES/${budslink-companion-uuid}.mo"
      done
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      extdir=$out/share/gnome-shell/extensions/${budslink-companion-uuid}
      mkdir -p "$extdir"
      cp -r extension.js prefs.js metadata.json stylesheet.css icons lib preferences schemas ui "$extdir/"
      if [ -d locale ]; then
        mkdir -p "$out/share"
        cp -r locale "$out/share/"
      fi
      runHook postInstall
    '';

    passthru.extensionUuid = budslink-companion-uuid;

    meta = with pkgs.lib; {
      description = "GNOME Shell panel companion for BudsLink";
      homepage = "https://github.com/maniacx/BudsLink-Companion";
      license = licenses.gpl3Plus;
      platforms = platforms.linux;
    };
  };
in
{
  home.packages = [
    budslink
    budslink-companion
  ];
}
