{ pkgs, ... }:

{
  services.flatpak.enable = true;

  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    path = [ pkgs.flatpak ];
    # switch-to-configuration restarts NetworkManager and resolved alongside
    # this unit, and DNS lags network-online at boot. --if-not-exists still
    # fetches the .flatpakrepo, so check locally first: once set up, this never
    # touches the network. Restart covers the first-ever run.
    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = "10s";
    };
    script = ''
      if ! flatpak remote-list --system --columns=name | grep -qx flathub; then
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      fi
      for ref in org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark; do
        flatpak info --system "$ref" >/dev/null 2>&1 \
          || flatpak install -y --noninteractive flathub "$ref"
      done
    '';
  };
}
