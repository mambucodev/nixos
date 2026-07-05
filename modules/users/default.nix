{ pkgs, ... }:

{
  users.users.mambuco = {
    isNormalUser = true;
    description = "Gabriele Giambrone";
    extraGroups = [ "wheel" "networkmanager" ];
    packages = with pkgs; [
      tree
    ];
  };
}
