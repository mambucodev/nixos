{ pkgs, ... }:

{
  programs.fish.enable = true;
  programs.starship.enable = true;

  users.defaultUserShell = pkgs.fish;

  environment.systemPackages = with pkgs; [
    git
    wget
    fish
    sbctl
    starship
  ];
}
