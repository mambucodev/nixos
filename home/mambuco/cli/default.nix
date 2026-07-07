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
    functions.nixs = ''
      xdg-open "https://search.nixos.org/packages?query=$argv"
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
