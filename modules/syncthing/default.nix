{ ... }:

{
  services.syncthing = {
    enable = true;
    user = "mambuco";
    group = "users";
    dataDir = "/home/mambuco";
    configDir = "/home/mambuco/.config/syncthing";
    openDefaultPorts = true;
    # Devices and folders are managed in the web UI; without these, any future
    # settings.* would make the init job delete everything added there.
    overrideDevices = false;
    overrideFolders = false;
  };
}
