{ ... }:

{
  # Enterprise policy for the whole Chromium family. Helium is a de-googled
  # Chromium fork that kept upstream's branding for this path, so it and
  # programs.chromium both read /etc/chromium/policies/managed — there is no
  # per-browser directory to split them into.
  #
  # These are mandatory policies: the matching settings render as managed and
  # greyed out. Move an entry to policies/recommended/ to make it a default the
  # UI can still change.
  #
  # Deliberately no DefaultSearchProvider* — setting one would override and lock
  # the search engine chosen during Helium's onboarding.
  environment.etc."chromium/policies/managed/nixos.json".text = builtins.toJSON {
    AutofillAddressEnabled = true;
    AutofillCreditCardEnabled = false;
    BackgroundModeEnabled = false;
    BookmarkBarEnabled = true;
    # No BrowserThemeColor: setting one swaps Chromium off following the GTK
    # theme and onto a generated palette, and the seed carries no light/dark
    # mode — the result renders light. There is no policy for the mode in this
    # build, so following adw-gtk3-dark is both simpler and a closer catppuccin
    # match than anything Chromium derives.
    DefaultBrowserSettingEnabled = false; # xdg.mimeApps already owns this
    DnsOverHttpsMode = "off"; # leave DNS to the system resolver (NextDNS)
    MetricsReportingEnabled = false;
    PasswordManagerEnabled = false; # Bitwarden owns logins
    PromotionalTabsEnabled = false;
    RestoreOnStartup = 1; # reopen last session
    ShowHomeButton = false;
    SpellcheckLanguage = [ "en-GB" "it" ];
  };
}
