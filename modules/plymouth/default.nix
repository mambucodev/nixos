{ pkgs, ... }:

let
  # Pull only the "dna" theme instead of the full ~524M adi1090x collection,
  # rewriting the absolute paths baked into its .plymouth file.
  dnaBase = pkgs.adi1090x-plymouth-themes.override { selected_themes = [ "dna" ]; };

  dnaTheme = pkgs.runCommand "plymouth-theme-dna-nixos" { } ''
    theme=$out/share/plymouth/themes/dna
    mkdir -p $out/share/plymouth/themes
    cp -r ${dnaBase}/share/plymouth/themes/dna $theme
    chmod -R u+w $theme

    sed -i "s,${dnaBase}/share/plymouth/themes/dna,$theme,g" $theme/dna.plymouth
  '';
in
{
  boot.plymouth = {
    enable = true;
    themePackages = [ dnaTheme ];
    theme = "dna";
  };

  # Quiet boot so the splash isn't drowned in kernel/udev logs.
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "splash"
    "udev.log_priority=3"
    "rd.udev.log_level=3"
    "boot.shell_on_fail"
  ];
}
