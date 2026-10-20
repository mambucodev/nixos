{ pkgs, ... }:

let
  catppuccin-gtksourceview = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "gedit";
    rev = "c118958d28298d80c869f06d4b8a794df9e0c2c5";
    hash = "sha256-ypKQfA912nZDCQK+NdhUyy/td3l1p816hx5QDxVtugE=";
  };
in
{
  xdg.dataFile."gtksourceview-5/styles/catppuccin-macchiato.xml".source =
    "${catppuccin-gtksourceview}/themes/catppuccin-macchiato.xml";

  dconf.settings."org/gnome/TextEditor".style-scheme = "catppuccin-macchiato";
}
