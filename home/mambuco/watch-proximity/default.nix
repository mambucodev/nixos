{ inputs, ... }:

{
  imports = [
    inputs.watch-proximity.homeManagerModules.default
  ];

  services.watch-proximity = {
    enable = true;
    deviceMac = "64:9D:38:1A:4F:5A";
    deviceName = "Pixel Watch 4";
    deskThreshold = 1;
    warningThreshold = -2;
    awayThreshold = -3;
    tolerance = 5;
    autoWake = true;
    pauseMedia = true;
    resumeMedia = true;
    antiTheft = true;
  };
}
