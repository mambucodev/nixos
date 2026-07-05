{ ... }:

{
  # resume_offset is the swapfile's physical block on the btrfs fs, from:
  #   btrfs inspect-internal map-swapfile -r /.swapvol/swapfile
  # Recompute if the swapfile is ever recreated.
  boot.resumeDevice = "/dev/mapper/cryptroot";
  boot.kernelParams = [ "resume_offset=533760" ];

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    # On AC keep running with the lid closed; battery still hibernates.
    HandleLidSwitchExternalPower = "ignore";
  };

  systemd.sleep.settings.Sleep.HibernateDelaySec = "2h";
}
