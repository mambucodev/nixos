{ inputs, ... }:

{
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];

  programs.spicetify = {
    enable = true;
    theme = {
      name = "catppuccin-clean";
      src = ./catppuccin-clean;
      injectCss = true;
      injectThemeJs = false;
      # user.css redefines the --spice-* vars that replaceColors generates
      replaceColors = true;
      overwriteAssets = false;
      homeConfig = true;
    };
    colorScheme = "mocha";
    enabledExtensions = [ ];
  };
}
