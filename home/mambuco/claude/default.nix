{ ... }:

{
  programs.claude-code = {
    enable = true;
    settings = {
#      theme = "catppuccin-macchiato-blue";
      tui = "fullscreen";
      permissions.defaultMode = "auto";
      # Plugins install into the writable ~/.claude/plugins dir, but the
      # enable flag has to live in settings.json — which nix owns read-only.
      # So declare enabled plugins here ("<name>@<marketplace>" = true).
      enabledPlugins = {
        "pyright-lsp@claude-plugins-official" = true;
        "frontend-design@claude-plugins-official" = true;
      };
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
