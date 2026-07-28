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
    # Seed for Chromium's dynamic palette, not a literal frame fill — the frame
    # is a derived dark tone of this hue. Macchiato blue, matching the accent
    # pinned in ../../home/mambuco/zen-browser.
    BrowserThemeColor = "#8aadf4";
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
