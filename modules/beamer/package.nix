{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  python3,
  libei,
  libxkbcommon,
  libxcb,
  nettools,
  makeWrapper,
  qt6,
}:

let
  # Upstream's Flatpak pins libei 1.6.0; nixpkgs is still on 1.5.
  libei' = libei.overrideAttrs (_: {
    version = "1.6.0";
    src = fetchurl {
      url = "https://gitlab.freedesktop.org/libinput/libei/-/archive/1.6.0/libei-1.6.0.tar.bz2";
      hash = "sha256-XtYHj6Y6/VVMwEsQAWdWFdoO2P4juASSq2NAMUC1qDA=";
    };
  });

  pythonEnv = python3.withPackages (ps: [
    ps.pyside6
    ps.pynacl
    ps.xlib
    ps.six
    ps.jeepney
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "beamer";
  version = "1.5.11";

  src = fetchFromGitHub {
    owner = "kalkman-code";
    repo = "beamer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2yZ81oQHb4q26qd9XGtyuhgGI5b31PcTsTpR4k2NR9I=";
  };

  nativeBuildInputs = [
    makeWrapper
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwayland
  ];

  dontWrapQtApps = true;

  # ctypes.util.find_library can't see the Nix store, so pin the libraries it dlopens.
  postPatch = ''
    substituteInPlace win_app/libei.py \
      --replace-fail 'ctypes.util.find_library("ei") or "libei.so.1"' '"${libei'}/lib/libei.so.1"'
    substituteInPlace win_app/capture_x11.py \
      --replace-fail 'ctypes.util.find_library("xkbcommon")' '"${libxkbcommon}/lib/libxkbcommon.so.0"'
    substituteInPlace win_app/xkb_x11.py \
      --replace-fail 'path = ctypes.util.find_library(name)' 'path = {"xcb": "${libxcb}/lib/libxcb.so.1", "xkbcommon": "${libxkbcommon}/lib/libxkbcommon.so.0", "xkbcommon-x11": "${libxkbcommon}/lib/libxkbcommon-x11.so.0"}.get(name)'
  '';

  installPhase = ''
    runHook preInstall

    install -d $out/share/beamer
    cp -r core win_app locales VERSION $out/share/beamer/
    rm -rf $out/share/beamer/core/tests $out/share/beamer/win_app/tests

    install -Dm644 flatpak/uk.co.kalkman.beamer.desktop $out/share/applications/uk.co.kalkman.beamer.desktop
    install -Dm644 Beamer.svg $out/share/icons/hicolor/scalable/apps/uk.co.kalkman.beamer.svg

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${pythonEnv}/bin/python3 $out/bin/beamer \
      "''${qtWrapperArgs[@]}" \
      --add-flags $out/share/beamer/win_app/kvm_bridge_win.py \
      --set PYTHONPATH $out/share/beamer/win_app:$out/share/beamer \
      --set PYTHONNOUSERSITE 1 \
      --prefix PATH : ${lib.makeBinPath [ nettools ]}
  '';

  meta = {
    description = "Software KVM sharing one keyboard and mouse across Mac, Windows and Linux";
    homepage = "https://beamerapp.co.uk";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "beamer";
  };
})
