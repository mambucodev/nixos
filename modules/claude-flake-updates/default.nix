{ pkgs, ... }:

{
  # Weekly refresh of the fast-moving Claude/Zed inputs (they track vendor CDNs).
  systemd.services.claude-flake-update = {
    description = "Refresh Claude-related and Zed flake inputs in /etc/nixos";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    path = with pkgs; [ nix git openssh ];

    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = "/etc/nixos";
      # Nix's libgit2 fetcher refuses repos not owned by the calling user,
      # and /etc/nixos belongs to mambuco — root can no longer update it.
      User = "mambuco";
    };

    script = ''
      nix flake update \
        claude-code-nix \
        claude-desktop-extra \
        claude-cowork-service \
        nixpkgs-zed
    '';
  };

  systemd.timers.claude-flake-update = {
    description = "Weekly refresh of Claude-related and Zed flake inputs";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };
}
