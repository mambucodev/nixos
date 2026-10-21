{ pkgs, ... }:

let
  catppuccin-gtksourceview = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "gedit";
    rev = "c118958d28298d80c869f06d4b8a794df9e0c2c5";
    hash = "sha256-ypKQfA912nZDCQK+NdhUyy/td3l1p816hx5QDxVtugE=";
  };

  # Upstream omits the version attribute, which GtkSourceView 5 requires.
  macchiato = pkgs.runCommand "catppuccin-macchiato-gtksourceview.xml" { } ''
    sed 's|<style-scheme id="catppuccin-macchiato"|<style-scheme version="1.0" id="catppuccin-macchiato"|' \
      ${catppuccin-gtksourceview}/themes/catppuccin-macchiato.xml > $out
  '';
in
{
  xdg.dataFile."gtksourceview-5/styles/catppuccin-macchiato.xml".source = macchiato;

  dconf.settings."org/gnome/TextEditor".style-scheme = "catppuccin-macchiato";
}
