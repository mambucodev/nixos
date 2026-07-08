{ pkgs, ... }:

{
  services.xserver.enable = true;

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-user-docs
    epiphany
    yelp
    gnome-console
    totem
    showtime
  ];

  documentation.nixos.enable = false;

  services.libinput.enable = true;
  services.printing.enable = true;

  # AccountsService sometimes marks root as a normal account, listing it in
  # the GDM chooser; wipe that state file on every activation.
  systemd.tmpfiles.rules = [
    "R /var/lib/AccountsService/users/root - - - - -"
  ];
}
