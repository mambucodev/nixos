{ pkgs, ... }:

{
  programs.fish.enable = true;
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = "[╭─](surface2) $directory$git_branch$git_status$line_break[╰─](surface2)$character";
      right_format = "$nix_shell$cmd_duration$time";
      directory = {
        style = "bold lavender";
        truncation_length = 1;
        format = "[$path]($style) ";
      };
      git_branch = {
        format = "[·](surface2) [$branch]($style)";
        style = "overlay1";
      };
      git_status = {
        format = "[ $all_status]($style)";
        style = "peach";
        modified = "•";
        untracked = "";
        staged = "+";
      };
      nix_shell = {
        format = "[nix]($style) ";
        style = "teal";
      };
      cmd_duration = {
        format = "[$duration]($style) ";
        style = "yellow";
      };
      time = {
        disabled = false;
        format = "[$time]($style)";
        style = "surface2";
        time_format = "%H:%M";
      };
      character = {
        success_symbol = "[›](bold green)";
        error_symbol = "[›](bold red)";
      };
      # catppuccin/nix only themes the home-manager starship module, not this system-level one
      palette = "catppuccin_mocha";
      palettes.catppuccin_mocha = {
        lavender = "#b4befe";
        peach = "#fab387";
        yellow = "#f9e2af";
        green = "#a6e3a1";
        teal = "#94e2d5";
        red = "#f38ba8";
        overlay1 = "#7f849c";
        surface2 = "#585b70";
      };
    };
  };

  users.defaultUserShell = pkgs.fish;

  environment.systemPackages = with pkgs; [
    git
    wget
    fish
    sbctl
    starship
  ];
}
