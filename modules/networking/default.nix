{ pkgs, ... }:

{
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
  networking.nameservers = [ "YOUR-PROFILE.dns.nextdns.io" ];

  environment.systemPackages = [ pkgs.openvpn ];

  services.openssh.enable = true;

  # go2tv serves media to DLNA renderers on 3500, stepping up if busy
  networking.firewall.allowedTCPPortRanges = [ { from = 3500; to = 3509; } ];
}
