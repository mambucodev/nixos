{ pkgs, ... }:

let
  zed-preview = pkgs.stdenv.mkDerivation rec {
    pname = "zed-editor-preview";
    version = "1.21.0-pre";

    src = pkgs.fetchurl {
      url = "https://github.com/zed-industries/zed/releases/download/v${version}/zed-linux-x86_64.tar.gz";
      hash = "sha256-6twwCYGWoKISmIpepNGT54ZB4XtFnkJ13ddnUXVEm0Q=";
    };

    sourceRoot = "zed-preview.app";

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.makeWrapper
    ];

    buildInputs = [
      pkgs.glib
      pkgs.alsa-lib
      pkgs.vulkan-loader
      pkgs.wayland
      pkgs.libxkbcommon
      pkgs.fontconfig
      pkgs.libGL
      pkgs.stdenv.cc.cc.lib
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/bin" "$out/libexec" "$out/lib" "$out/share/applications"

      cp -r lib/* "$out/lib/"
      cp -r share/* "$out/share/"
      cp libexec/zed-editor "$out/libexec/zed-editor"
      cp bin/zed "$out/bin/zed"

      ln -s "$out/bin/zed" "$out/bin/zeditor"
      ln -sf "$out/share/applications/dev.zed.Zed-Preview.desktop" "$out/share/applications/dev.zed.Zed.desktop"

      wrapProgram "$out/libexec/zed-editor" \
        --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [ pkgs.vulkan-loader pkgs.libGL pkgs.wayland ]}"

      wrapProgram "$out/bin/zed" \
        --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [ pkgs.vulkan-loader pkgs.libGL pkgs.wayland ]}"

      runHook postInstall
    '';
  };
in
{
  programs.zed-editor = {
    enable = true;
    package = zed-preview;
  };
}
