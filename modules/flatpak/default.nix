{ pkgs, ... }:

{
  services.flatpak.enable = true;

  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    path = [ pkgs.flatpak ];
    serviceConfig.Type = "oneshot";
    script = ''
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      flatpak install -y --noninteractive flathub org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark
    '';
  };
}
