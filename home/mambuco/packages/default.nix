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

  # GNOME disables extensions on lock, taking down the StatusNotifierWatcher;
  # apps hidden in the tray (Spotify) then re-show their window on unlock.
  # Stay alive in unlock-dialog, but hide the icons there: the shell only hides
  # its own indicators, so tray menus would otherwise work on the lock screen.
  appindicator = pkgs.gnomeExtensions.appindicator.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace metadata.json --replace-fail \
        '"settings-schema":' \
        '"session-modes": ["user", "unlock-dialog"], "settings-schema":'

      substituteInPlace indicatorStatusIcon.js --replace-fail \
        "settings.get_string('tray-pos'));" \
        "settings.get_string('tray-pos'));
          statusIcon.container.visible = !Main.sessionMode.isLocked;"

      substituteInPlace extension.js \
        --replace-fail \
          "import * as Extension from" \
          "import * as Main from 'resource:///org/gnome/shell/ui/main.js';
          import * as Extension from" \
        --replace-fail \
          "TrayIconsManager.TrayIconsManager.initialize();" \
          "TrayIconsManager.TrayIconsManager.initialize();
          this._sessionModeId = Main.sessionMode.connect('updated', () => {
              for (const [role, indicator] of Object.entries(Main.panel.statusArea)) {
                  if (role.startsWith('appindicator-'))
                      indicator.container.visible = !Main.sessionMode.isLocked;
              }
          });" \
        --replace-fail \
          "TrayIconsManager.TrayIconsManager.destroy();" \
          "TrayIconsManager.TrayIconsManager.destroy();
          Main.sessionMode.disconnect(this._sessionModeId);"
    '';
  });
in
{
  home.packages = [
    pkgs.sshfs
    pkgs.sox
    pkgs.wl-clipboard  # Claude Code reads pasted images via wl-paste
    pkgs.apostrophe
    clapper
    pkgs.bitwarden-desktop
    antigravity.google-antigravity
    antigravity.google-antigravity-ide
    antigravity.google-antigravity-cli
    pkgs.gnomeExtensions.hibernate-status-button
    appindicator
    pkgs.gjs # appindicator spawns `gjs` to rediscover tray icons already on the bus
    pkgs.gnomeExtensions.media-controls
    pkgs.gnomeExtensions.top-bar-organizer
    pkgs.gnomeExtensions.clipboard-indicator
    pkgs.gnomeExtensions.caffeine
    pkgs.gnomeExtensions.activate-window-by-title  # D-Bus window raiser; used by the `nixs` fish function
    dash-to-dock
    pkgs.libreoffice
    pkgs.signal-desktop
    pkgs.telegram-desktop
    pkgs.teams-for-linux
    pkgs.proton-vpn
    pkgs.stremio-linux-shell
    pkgs.figma-linux
    pkgs.aseprite
    pkgs.cartero
    pkgs.newsflash
    pkgs.fragments
    pkgs.alpaca
    pkgs.mission-center
    (pkgs.obsidian.overrideAttrs (old: {
      postFixup = (old.postFixup or "") + ''
        echo "StartupWMClass=md.obsidian.Obsidian" >> $out/share/applications/obsidian.desktop
      '';
    }))
  ];
}
