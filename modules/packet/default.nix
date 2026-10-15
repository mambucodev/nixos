{ lib, pkgs, ... }:

let
  port = 9300;
in
{
  # nautilus-python loads Packet's "Send with Packet" context-menu extension.
  environment.systemPackages = [ pkgs.packet pkgs.nautilus-python ];

  # Packet picks a random port unless told otherwise, which the firewall would
  # block. Discovery is mDNS (opened by modules/avahi).
  programs.dconf.profiles.user.databases = [{
    settings."io/github/nozwock/Packet" = {
      enable-static-port = true;
      static-port-number = lib.gvariant.mkInt32 port;
      # The login entry itself is home/mambuco/gnome/apps.nix; these keep the
      # in-app toggles in sync and keep it alive when the window is closed.
      run-in-background = true;
      auto-start = true;
    };
  }];

  networking.firewall.allowedTCPPorts = [ port ];
}
