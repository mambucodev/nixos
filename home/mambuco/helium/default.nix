{ inputs, pkgs, ... }:

let
  heliumPkg = inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.helium;
  customTheme = pkgs.runCommand "helium-catppuccin-macchiato-theme" { } ''
    mkdir -p $out
    cp ${./theme/manifest.json} $out/manifest.json
    cp ${./theme/wallpaper.jpg} $out/wallpaper.jpg
  '';
  wrappedHelium = pkgs.symlinkJoin {
    name = "helium";
    paths = [ heliumPkg ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm $out/bin/helium
      makeWrapper ${heliumPkg}/bin/helium $out/bin/helium \
        --add-flags "--load-extension=${customTheme}"
    '';
  };
in
{
  home.packages = [ wrappedHelium ];

  home.sessionVariables.BROWSER = "helium";
}
