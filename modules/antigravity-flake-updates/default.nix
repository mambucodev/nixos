{ pkgs, ... }:

{
  # Weekly refresh of fast-moving flake inputs (antigravity).
  systemd.services.antigravity-flake-update = {
    description = "Refresh Antigravity flake input in /etc/nixos";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    path = with pkgs; [ nix git openssh ];

    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = "/etc/nixos";
      User = "mambuco";
    };

    script = ''
      nix flake update \
        antigravity
    '';
  };

  systemd.timers.antigravity-flake-update = {
    description = "Weekly refresh of Antigravity flake input";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };
}
