{ ... }:

{
  # Enabling the HM module lets catppuccin.vesktop paint Discord (routes the
  # CSS through vencord). Note: settings.json becomes a managed symlink, so
  # plugin tweaks must go through vencord.settings, not the in-app toggles.
  programs.vesktop.enable = true;

  # arRPC exposes the discord-ipc socket that music-discord-rpc writes to
  # (see discord-rpc). Lands in ~/.config/vesktop/settings.json.
  programs.vesktop.settings.arRPC = true;
}
