{ inputs, ... }:

let
  # Pin the existing on-disk Zen profile (random prefix set on first run) so the
  # HM firefox module doesn't recreate it and orphan bookmarks/logins/extensions.
  profileDir = ".config/zen/ubxbwjh3.Default Profile";
in
{
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
    policies = {
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisableTelemetry = true;
      OfferToSaveLogins = false;
    };
  };

  home.file = {
    "${profileDir}/chrome/userChrome.css".source = ./catppuccin/userChrome.css;
    "${profileDir}/chrome/userContent.css".source = ./catppuccin/userContent.css;
    "${profileDir}/chrome/zen-logo-macchiato.svg".source = ./catppuccin/zen-logo-macchiato.svg;
    "${profileDir}/user.js".text = ''
      user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

      // catppuccin chrome is gated on prefers-color-scheme: dark — force the match.
      user_pref("ui.systemUsesDarkTheme", 1);

      // Disable Zen's per-workspace color overlays so only the catppuccin CSS paints.
      user_pref("zen.theme.color-prefs.use-workspace-colors", false);
      user_pref("zen.theme.color-prefs.colorful-tabs-background", false);
      user_pref("zen.theme.acrylic-elements", false);

      // Pin the accent to the catppuccin macchiato blue so the picker stops fighting.
      user_pref("zen.theme.accent-color", "#8aadf4");
    '';
  };
}
