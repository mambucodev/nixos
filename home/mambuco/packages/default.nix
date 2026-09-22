{ inputs, pkgs, ... }:

let
  # Clapper omits gst-libav, so it can't software-decode H.265 when VA-API bails.
  clapper = pkgs.clapper.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ pkgs.gst_all_1.gst-libav ];
  });

  antigravity =
    inputs.antigravity.packages.${pkgs.stdenv.hostPlatform.system};

  # Upstream has no edge-margin setting; the dock pill sits 4px off the edge.
  dash-to-dock = pkgs.gnomeExtensions.dash-to-dock.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      cat >> stylesheet.css <<'EOF'
      #dashtodockContainer.bottom #dash { margin-bottom: 10px; }
      EOF
    '';
  });
in
{
  home.packages = [
    pkgs.sshfs
    pkgs.apostrophe
    clapper
    pkgs.bitwarden-desktop
    antigravity.google-antigravity
    antigravity.google-antigravity-ide
    antigravity.google-antigravity-cli
    pkgs.gnomeExtensions.hibernate-status-button
    pkgs.gnomeExtensions.appindicator
    pkgs.gnomeExtensions.media-controls
    pkgs.gnomeExtensions.top-bar-organizer
    pkgs.gnomeExtensions.activate-window-by-title  # D-Bus window raiser; used by the `nixs` fish function
    dash-to-dock
    pkgs.libreoffice
    pkgs.telegram-desktop
    pkgs.teams-for-linux
    pkgs.proton-vpn
    pkgs.stremio-linux-shell
    pkgs.figma-linux
    pkgs.cartero
    pkgs.newsflash
    (pkgs.obsidian.overrideAttrs (old: {
      postFixup = (old.postFixup or "") + ''
        echo "StartupWMClass=md.obsidian.Obsidian" >> $out/share/applications/obsidian.desktop
      '';
    }))
  ];
}
