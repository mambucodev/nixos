{ lib, pkgs, ... }:

let
  # Keys we want enforced declaratively. Everything else in settings.json
  # (model, effort, /config toggles, …) is left for Claude Code to own.
  managed = {
    tui = "fullscreen";
    permissions.defaultMode = "auto";
    # Plugins install into the writable ~/.claude/plugins dir, but the
    # enable flag has to live in settings.json ("<name>@<marketplace>" = true).
    enabledPlugins = {
      "pyright-lsp@claude-plugins-official" = true;
      "frontend-design@claude-plugins-official" = true;
    };
    attribution = {
      commit = "";
      pr = "";
    };
  };
  managedFile = (pkgs.formats.json { }).generate "claude-managed-settings.json" managed;
in
{
  programs.claude-code.enable = true;

  # Do NOT set programs.claude-code.settings: that symlinks settings.json into
  # the store read-only, so Claude Code can't persist runtime changes (effort,
  # model, /config). Instead deep-merge our managed keys into the live file on
  # activation — declared keys win, runtime-only keys are preserved.
  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    cfg="$HOME/.claude/settings.json"
    run mkdir -p "$HOME/.claude"
    # Drop a read-only symlink left by a previous generation.
    [ -L "$cfg" ] && run rm -f "$cfg"
    if [ -f "$cfg" ]; then
      run ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$cfg" ${managedFile} > "$cfg.tmp" \
        && run mv "$cfg.tmp" "$cfg"
    else
      run install -m644 ${managedFile} "$cfg"
    fi
  '';

  # Claude Desktop reads its active theme from this file (themes ship with the bin).
#  xdg.configFile."Claude/claude-desktop-bin.json".source =
#    ./catppuccin-macchiato.json;
}
