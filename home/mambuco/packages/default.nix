{ inputs, pkgs, ... }:

let
  # Cider 2 pinned ahead of nixpkgs (3.1.8). Fallback: replace `cider` with pkgs.cider-2.
  cider = pkgs.cider-2.overrideAttrs (old: {
    version = "4.0.0";
    src = pkgs.fetchurl {
      url = "https://repo.cider.sh/apt/pool/main/cider-v4.0.0-linux-x64.deb";
      hash = "sha256-Z5B7VQatTEktt4e7aF5EGDTufgwfRHJzCZ1Lia/aIFk=";
    };
    # v4 dropped the popup-handler the upstream patch targets; skip the asar
    # repack and keep only the Widevine symlink for Apple Music DRM.
    postInstall = ''
      ln -sf ${pkgs.widevine-cdm}/share/google/chrome/WidevineCdm $out/lib/cider/
    '';
    # Running window's Wayland app_id is `cider` (lowercase); nixpkgs ships
    # StartupWMClass=Cider, which won't bind window→launcher in GNOME.
    postFixup = (old.postFixup or "") + ''
      substituteInPlace $out/share/applications/cider-2.desktop \
        --replace-fail 'StartupWMClass=Cider' 'StartupWMClass=cider'
    '';
  });

  # Clapper omits gst-libav, so it can't software-decode H.265 when VA-API bails.
  clapper = pkgs.clapper.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ pkgs.gst_all_1.gst-libav ];
  });
in
{
  home.packages = [
    pkgs.fastfetch
    pkgs.sshfs
    pkgs.apostrophe
    clapper
    pkgs.bitwarden-desktop
    inputs.claude-desktop-bin.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.gnomeExtensions.hibernate-status-button
    pkgs.gnomeExtensions.appindicator
    pkgs.gnomeExtensions.media-controls
    pkgs.gnomeExtensions.top-bar-organizer
    pkgs.gnomeExtensions.activate-window-by-title  # D-Bus window raiser; used by the `nixs` fish function
    pkgs.libreoffice
    pkgs.telegram-desktop
    pkgs.teams-for-linux
    pkgs.proton-vpn
    pkgs.stremio-linux-shell
    pkgs.figma-linux
    pkgs.cartero
    cider
  ];
}
