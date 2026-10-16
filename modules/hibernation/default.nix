{ config, lib, ... }:

{
  # Resume from the host's swap partition. A swapfile would also need resume_offset.
  boot.resumeDevice = lib.mkIf (config.swapDevices != [ ])
    (lib.mkDefault (builtins.head config.swapDevices).device);

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    # On AC keep running with the lid closed; battery still hibernates.
    HandleLidSwitchExternalPower = "ignore";
  };

  systemd.sleep.settings.Sleep.HibernateDelaySec = "2h";
}
