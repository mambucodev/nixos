{ ... }:

{
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  services.fwupd.enable = true;
  services.power-profiles-daemon.enable = true;
}
