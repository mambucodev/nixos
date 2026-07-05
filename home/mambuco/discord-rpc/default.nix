{ pkgs, ... }:

{
  # Bridges an MPRIS player's "now playing" into Discord via Vesktop's arRPC
  # socket. Allowlist-only (empty = every player); match the MPRIS Identity
  # (`music-discord-rpc -l`). Cider is excluded — it has native Rich Presence.
  systemd.user.services.music-discord-rpc = {
    Unit = {
      Description = "MPRIS -> Discord rich presence";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      ExecStart = ''
        ${pkgs.music-discord-rpc}/bin/music-discord-rpc \
          --interval 10 \
          --allowlist-add "Clapper"
      '';
      Restart = "on-failure";
      RestartSec = 15;
    };
  };
}
