{ ... }:

{
  services.syncthing = {
    enable = true;
    user = "mambuco";
    group = "users";
    dataDir = "/home/mambuco";
    configDir = "/home/mambuco/.config/syncthing";
    openDefaultPorts = true;
  };
}
