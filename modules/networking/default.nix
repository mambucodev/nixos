{ pkgs, ... }:

{
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];

  # Local stub resolver so /etc/resolv.conf is always "nameserver 127.0.0.53",
  # identical and parseable on every network. Routers that advertise scoped
  # link-local nameservers (fe80::...%wlan) otherwise land verbatim in
  # resolv.conf, which glibc tolerates but Chromium's resolver rejects wholesale
  # — every request in Helium then dies with ERR_NAME_NOT_RESOLVED.
  services.resolved.enable = true;

  # The NextDNS profile ID is a secret this public repo must not carry. It goes
  # in /etc/systemd/resolved.conf.d/50-nextdns.conf, hand-copied from the
  # .example below (shipped here, inert for systemd) — rebuilds never touch it.
  environment.etc."systemd/resolved.conf.d/50-nextdns.conf.example".text = ''
    [Resolve]
    DNS=45.90.28.0#PROFILE.dns.nextdns.io 2a07:a8c0::#PROFILE.dns.nextdns.io 45.90.30.0#PROFILE.dns.nextdns.io 2a07:a8c1::#PROFILE.dns.nextdns.io
    DNSOverTLS=yes
    Domains=~.
  '';

  environment.systemPackages = [ pkgs.openvpn ];

  services.openssh.enable = true;
}
