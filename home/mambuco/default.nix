{ ... }:

{
  imports = [
    ./packages
    ./cli
    ./fastfetch
    ./git
    ./ssh
    ./zen-browser
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
    ./cast
  ];

  home.username = "mambuco";
  home.homeDirectory = "/home/mambuco";

  home.stateVersion = "26.05";
}
