{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gnome-catppuccin-mocha
    gnomeExtensions.user-themes
  ];
}
