{ ... }:

{
  imports = [
    ./packages
    ./cli
    ./fastfetch
    ./git
    ./ssh
    ./helium
    ./gnome
    ./neovim
    ./zed
    ./chromium
    ./theme
    ./flatpak
    ./vesktop
    ./discord-rpc
    ./dev
    ./budslink
    ./spotify
    ./claude
    ./libreoffice
  ];

  home.username = "mambuco";
  home.homeDirectory = "/home/mambuco";

  home.stateVersion = "26.05";
}
