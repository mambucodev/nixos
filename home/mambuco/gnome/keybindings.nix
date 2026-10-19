{ lib, pkgs, ... }:

let
  launchers = [
    { name = "Ghostty"; binding = "<Super>t"; command = "ghostty"; }
    { name = "Helium"; binding = "<Super>b"; command = "helium"; }
    { name = "Obsidian"; binding = "<Super>o"; command = "obsidian"; }
    { name = "Settings"; binding = "<Super>i"; command = "gnome-control-center"; }
    { name = "Calendar"; binding = "<Super>c"; command = "gnome-calendar"; }
    { name = "Mission Center"; binding = "<Control><Shift>Escape"; command = "missioncenter"; }
    { name = "btop"; binding = "<Super><Shift>t"; command = "ghostty -e btop"; }
    { name = "Keybindings"; binding = "<Super>less"; command = "${toggleCheatsheet}"; }
  ];

  wm = [
    { key = "close"; name = "Close window"; binding = "<Super>q"; }
    { key = "show-desktop"; name = "Show desktop"; binding = "<Super>d"; }
    { key = "toggle-fullscreen"; name = "Toggle fullscreen"; binding = "<Super>f"; }
  ];

  dockBinding = "<Super>z";

  keys = binding:
    map (k: if lib.stringLength k == 1 then lib.toUpper k else k)
      (lib.splitString "+" (lib.replaceStrings
        [ "<Super>" "<Shift>" "<Control>" "<Alt>" "Escape" "less" ]
        [ "Super+" "Shift+" "Ctrl+" "Alt+" "Esc" "<" ]
        binding));

  row = binding: action: { keys = keys binding; inherit action; };

  # One inner list per column. Non-launcher rows are GNOME defaults, listed for completeness.
  columns = [
    [
      { title = "Apps"; rows = map (l: row l.binding l.name) launchers; }
    ]
    [
      { title = "Windows"; rows = map (w: row w.binding w.name) wm; }
      {
        title = "Workspaces";
        rows = [
          { keys = [ "Super" "PgUp" "/" "PgDn" ]; action = "Previous / next"; }
          { keys = [ "Super" "Shift" "PgUp" "/" "PgDn" ]; action = "Move window"; }
        ];
      }
    ]
    [
      {
        title = "Dock";
        rows = [
          (row dockBinding "Reveal dock")
          { keys = [ "Super" "1…9" ]; action = "Open app N"; }
        ];
      }
      {
        title = "System";
        rows = [
          (row "<Super>e" "Home folder")
          (row "<Super>a" "App grid")
          (row "<Super>s" "Quick settings")
          (row "<Super><Shift>s" "Screenshot")
          (row "<Super>v" "Clipboard history")
          (row "<Super>m" "Notifications")
          (row "<Super>l" "Lock screen")
        ];
      }
    ]
  ];

  cheatsheet = pkgs.stdenvNoCC.mkDerivation {
    name = "keybindings-cheatsheet";
    dontUnpack = true;
    nativeBuildInputs = [ pkgs.wrapGAppsHook4 pkgs.gobject-introspection ];
    buildInputs = [ pkgs.gtk4 pkgs.libadwaita (pkgs.python3.withPackages (p: [ p.pygobject3 ])) ];
    installPhase = ''
      install -Dm755 ${./cheatsheet.py} $out/bin/keybindings-cheatsheet
      # Adwaita's GNOME foot, shipped directly: Papirus overrides start-here with an app grid.
      install -Dm644 ${./super-symbolic.svg} $out/share/icons/super-symbolic.svg
      patchShebangs $out/bin
    '';
    preFixup = ''
      gappsWrapperArgs+=(--add-flags ${pkgs.writeText "keybindings.json" (builtins.toJSON columns)})
    '';
  };

  # Pokes the resident instance over D-Bus (no Python startup); launches it if the service isn't up.
  toggleCheatsheet = pkgs.writeShellScript "toggle-keybindings-cheatsheet" ''
    ${lib.getExe' pkgs.glib "gdbus"} call --session \
      --dest local.mambuco.KeybindingsCheatsheet \
      --object-path /local/mambuco/KeybindingsCheatsheet \
      --method org.freedesktop.Application.Activate '{}' >/dev/null 2>&1 \
      || exec ${cheatsheet}/bin/keybindings-cheatsheet
  '';

  emptyBinding = lib.hm.gvariant.mkEmptyArray lib.hm.gvariant.type.string;

  customPath = i: "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${toString i}/";
in
{
  # Filename must match the GTK application id so the dock picks up the icon.
  xdg.desktopEntries."local.mambuco.KeybindingsCheatsheet" = {
    name = "Keyboard Shortcuts";
    exec = "${toggleCheatsheet}";
    icon = "preferences-desktop-keyboard-shortcuts";
    noDisplay = true;
  };

  systemd.user.services.keybindings-cheatsheet = {
    Unit = {
      Description = "Keybindings cheat sheet (preloaded)";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      ExecStart = "${cheatsheet}/bin/keybindings-cheatsheet --gapplication-service";
      Restart = "on-failure";
    };
  };

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      home = [ "<Super>e" ];
      custom-keybindings = lib.imap0 (i: _: customPath i) launchers;
    };

    "org/gnome/shell/keybindings" = {
      show-screenshot-ui = [ "Print" "<Super><Shift>s" ];
      toggle-message-tray = [ "<Super>m" ];
    };

    # Only Super+V; the extension's other Ctrl+F8–F12 defaults would shadow app shortcuts.
    "org/gnome/shell/extensions/clipboard-indicator" = {
      toggle-menu = [ "<Super>v" ];
      clear-history = emptyBinding;
      prev-entry = emptyBinding;
      next-entry = emptyBinding;
      private-mode-binding = emptyBinding;
    };

    "org/gnome/desktop/wm/keybindings" = lib.listToAttrs (map (w: lib.nameValuePair w.key [ w.binding ]) wm);

    "org/gnome/shell/extensions/dash-to-dock" = {
      shortcut = [ dockBinding ];
      shortcut-text = dockBinding;
    };
  } // lib.listToAttrs (lib.imap0 (i: l:
    lib.nameValuePair (lib.removeSuffix "/" (lib.removePrefix "/" (customPath i))) {
      inherit (l) binding command;
      name = "Open ${l.name}";
    }) launchers);
}
