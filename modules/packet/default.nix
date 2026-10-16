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
      # Keeps it alive when the window is closed. auto-start stays off so the
      # portal doesn't write a duplicate entry next to the one in
      # home/mambuco/gnome/apps.nix.
      run-in-background = true;
      auto-start = false;
    };
  }];

  networking.firewall.allowedTCPPorts = [ port ];
}
