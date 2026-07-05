{ inputs, pkgs, ... }:

{
  imports = [
    inputs.claude-cowork-service.nixosModules.default
  ];

  services.claude-cowork = {
    enable = true;
    # Pin the package so the module's default (which reads the deprecated
    # pkgs.system alias) is never evaluated. extraPath = the claude-code CLI
    # the service shells out to.
    package = inputs.claude-cowork-service.packages.${pkgs.stdenv.hostPlatform.system}.claude-cowork-service;
    extraPath = [ pkgs.claude-code ];
  };
}
