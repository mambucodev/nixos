{ lib, ... }:

{
  time.timeZone = "Europe/Rome";
  i18n.defaultLocale = "en_GB.UTF-8";

  console = {
    keyMap = "it";
    useXkbConfig = false;
  };

  services.xserver.xkb.layout = "it";

  # GNOME/Wayland rewrites input-sources back to 'us' each login (en_GB carries
  # no IT default), clobbering any user-level dconf write. A system dconf lock
  # is the only thing that makes the IT layout stick.
  programs.dconf.profiles.user.databases = [{
    settings."org/gnome/desktop/input-sources" = {
      sources = [ (lib.gvariant.mkTuple [ "xkb" "it" ]) ];
    };
    locks = [
      "/org/gnome/desktop/input-sources/sources"
    ];
  }];
}
