{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gnome-catppuccin-macchiato
    gnomeExtensions.user-themes
  ];
}
