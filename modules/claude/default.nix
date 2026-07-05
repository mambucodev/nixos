{ pkgs, ... }:

let
  themeName = "catppuccin-macchiato-blue";
  themeFile = ./themes/catppuccin-macchiato-blue.json;
in
{
  # `sudo claude` uses HOME=/root, so mirror mambuco's theme there. settings.json
  # is rewritten by claude-code at runtime, so merge the theme key rather than
  # clobbering; the theme file itself is a symlink and always current.
  system.activationScripts.claudeRootTheme = ''
    install -d -m 0700 -o root -g root /root/.claude /root/.claude/themes
    ln -sfn ${themeFile} /root/.claude/themes/${themeName}.json
    if [ -f /root/.claude/settings.json ]; then
      ${pkgs.jq}/bin/jq '.theme = "${themeName}"' /root/.claude/settings.json \
        > /root/.claude/settings.json.tmp \
        && mv /root/.claude/settings.json.tmp /root/.claude/settings.json
    else
      echo '{"theme":"${themeName}"}' > /root/.claude/settings.json
    fi
    chmod 0600 /root/.claude/settings.json
  '';
}
