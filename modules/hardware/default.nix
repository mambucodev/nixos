{ ... }:

{
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  # HP G8-family BIOS bug: resume from s2idle can die with the platform
  # powered but the screen permanently black. IOMMU passthrough is the
  # confirmed workaround on sibling models (EliteBook 840/845 G8).
  boot.kernelParams = [ "iommu=pt" ];

  services.fwupd.enable = true;
  services.power-profiles-daemon.enable = true;

  # The DPTF skin/VRM sensors (SEN1/SEN2) trip at 80 °C and the EC hard-cuts
  # power, while the kernel never throttles on them. thermald reads the DPTF
  # tables and throttles the CPU before that point.
  services.thermald.enable = true;
}
