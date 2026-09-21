{ pkgs, ... }:

{
  # Weekly refresh of fast-moving flake inputs (antigravity, nixpkgs-zed).
  systemd.services.antigravity-flake-update = {
    description = "Refresh Antigravity and Zed flake inputs in /etc/nixos";
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
        antigravity \
        nixpkgs-zed
    '';
  };

  systemd.timers.antigravity-flake-update = {
    description = "Weekly refresh of Antigravity and Zed flake inputs";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };
}
