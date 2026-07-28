{ ... }:

{
  imports = [
    ./packages
    ./cli
    ./fastfetch
    ./git
    ./ssh
    ./zen-browser
    ./helium
    ./gnome
    ./neovim
    ./zed
    ./chromium
    ./theme
    ./vesktop
    ./discord-rpc
    ./dev
    ./claude
    ./budslink
  ];

  home.username = "mambuco";
  home.homeDirectory = "/home/mambuco";

  home.stateVersion = "26.05";
}
