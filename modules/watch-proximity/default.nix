{ inputs, ... }:

{
  imports = [
    inputs.watch-proximity.nixosModules.default
  ];

  security.pam.watch-proximity.enable = true;
}
