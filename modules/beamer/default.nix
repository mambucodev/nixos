{ pkgs, ... }:

{
  environment.systemPackages = [ (pkgs.callPackage ./package.nix { }) ];

  # TCP for input, UDP for pairing.
  networking.firewall.allowedTCPPorts = [ 24820 ];
  networking.firewall.allowedUDPPorts = [ 24821 ];
}
