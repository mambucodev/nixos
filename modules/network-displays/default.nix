{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.gnome-network-displays ];

  # Discovery is mDNS (opened by modules/avahi). These are the sink-side ports:
  networking.firewall = {
    # Miracast WFD RTSP control server.
    allowedTCPPorts = [ 7236 ];
    # Chromecast pulls the transcoded HTTP stream from an ephemeral port.
    allowedTCPPortRanges = [ { from = 32768; to = 60999; } ];
  };
}
