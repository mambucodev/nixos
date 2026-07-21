{ pkgs, ... }:

{
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
  networking.nameservers = [ "YOUR-PROFILE.dns.nextdns.io" ];

  environment.systemPackages = [ pkgs.openvpn ];

  services.openssh.enable = true;
}
