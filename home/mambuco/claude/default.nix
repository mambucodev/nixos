{ ... }:

{
  programs.claude-code = {
    enable = true;
    settings = {
#      theme = "catppuccin-macchiato-blue";
      attribution = {
        commit = "";
        pr = "";
      };
    };
  };

  # Claude Desktop reads its active theme from this file (themes ship with the bin).
#  xdg.configFile."Claude/claude-desktop-bin.json".source =
#    ./catppuccin-macchiato.json;
}
