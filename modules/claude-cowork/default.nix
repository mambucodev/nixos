{ inputs, pkgs, ... }:

{
  imports = [
    inputs.claude-cowork-service.nixosModules.default
  ];

  # extraPath supplies the claude-code CLI the service shells out to.
  services.claude-cowork = {
    enable = true;
    extraPath = [ pkgs.claude-code ];
  };
}
