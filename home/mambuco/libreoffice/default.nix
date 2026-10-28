{ pkgs, ... }:

let
  themeName = "adw-gtk3-dark-libreoffice";
in
{
  home.packages = [
    (pkgs.libreoffice.override {
      extraMakeWrapperArgs = [ "--set" "GTK_THEME" themeName ];
    })
  ];

  # LibreOffice's gtk3 backend paints disabled toolbar text with the `.view`
  # background nudged 8 steps away from the window background. With both at
  # mocha base that text vanishes, so LibreOffice alone gets surface2 here,
  # which yields an overlay0-ish disabled colour. Real GTK views keep theirs.
  xdg.dataFile."themes/${themeName}/gtk-3.0/gtk.css".text = ''
    @import url("file://${pkgs.adw-gtk3}/share/themes/adw-gtk3-dark/gtk-3.0/gtk.css");

    .view:not(iconview):not(treeview):not(textview):not(flowbox):not(list) {
      background-color: #585b70;
    }
  '';
}
