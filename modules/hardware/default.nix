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
}
