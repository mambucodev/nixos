{ inputs, pkgs, ... }:

{
  home.packages = [ inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.helium ];

  home.sessionVariables.BROWSER = "helium";
}
