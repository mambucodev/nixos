{ pkgs, ... }:

{
  home.packages = with pkgs; [
    jq
    awscli2
    kubectl
    ssm-session-manager-plugin  # `aws ssm start-session`; macOS' `--cask session-manager-plugin`
  ];

  programs.fish = {
    enable = true;
    shellAliases.hibernate = "systemctl hibernate";
    # Open the search in helium, then raise its window. GNOME Wayland ignores an
    # app's own focus request without a valid activation token (which a terminal
    # launch doesn't carry), so we ask the activate-window-by-title extension to
    # present the window by wm_class over D-Bus. Chromium derives that class from
    # its desktop name, and which case ozone hands to Wayland isn't worth pinning
    # down here — try both and stop at the one that reports found.
    functions.nixs = ''
      helium "https://search.nixos.org/packages?query=$argv" &
      for class in Helium helium
        set -l found (gdbus call --session --dest org.gnome.Shell \
          --object-path /de/lucaswerkmeister/ActivateWindowByTitle \
          --method de.lucaswerkmeister.ActivateWindowByTitle.activateByWmClass $class 2>/dev/null)
        if string match -q '(true,)' -- "$found"
          break
        end
      end
    '';
  };

  programs.ghostty = {
    enable = true;
    settings = {
      window-width = 90;  # cells, not pixels
      window-height = 30;
    };
  };

  # Makes ghostty the default for Nautilus "Open in Terminal" etc.
  xdg.configFile."xdg-terminals.list".text = ''
    com.mitchellh.ghostty.desktop
  '';

  programs.btop.enable = true;
  programs.eza.enable = true;
  programs.bat.enable = true;
  programs.ripgrep.enable = true;
  programs.fd.enable = true;

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.lazygit.enable = true;
  programs.gh.enable = true;
}
