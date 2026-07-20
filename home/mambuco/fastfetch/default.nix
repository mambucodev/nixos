{ ... }:

{
  # catppuccin/nix has no fastfetch port — Mocha colors are hand-set as
  # 24-bit ANSI (blue 89b4fa, lavender b4befe, overlay0 6c7086).
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "nixos_small";
        padding = {
          top = 5;
          left = 2;
          right = 5;
        };
        # the builtin art references color slots 3-6 too; unset ones fall
        # back to palette blue/cyan, which Ghostty's theme renders as teal
        color = {
          "1" = "38;2;137;180;250";
          "2" = "38;2;180;190;254";
          "3" = "38;2;137;180;250";
          "4" = "38;2;180;190;254";
          "5" = "38;2;137;180;250";
          "6" = "38;2;180;190;254";
        };
      };
      display = {
        separator = "  ";
        key.width = 12;
        color = {
          title = "38;2;137;180;250";
          keys = "38;2;180;190;254";
          separator = "38;2;108;112;134";
        };
      };
      modules = [
        {
          type = "title";
          format = "{user-name}@{host-name}";
        }
        {
          type = "separator";
          string = "─";
        }
        {
          type = "os";
          key = " OS";
          format = "{name} {version}";
        }
        {
          type = "host";
          key = "󰌢 Host";
          format = "{name}";
        }
        {
          type = "kernel";
          key = "󰌽 Kernel";
        }
        {
          type = "uptime";
          key = "󰅐 Uptime";
        }
        {
          type = "packages";
          key = "󰏖 Packages";
        }
        {
          type = "shell";
          key = " Shell";
        }
        {
          type = "display";
          key = "󰍹 Display";
        }
        {
          type = "de";
          key = "󰇄 DE";
        }
        {
          type = "terminal";
          key = "󰆍 Terminal";
        }
        {
          type = "cpu";
          key = "󰻠 CPU";
        }
        {
          type = "gpu";
          key = "󰢮 GPU";
        }
        {
          type = "memory";
          key = "󰍛 Memory";
        }
        {
          type = "disk";
          key = "󰋊 Disk";
          folders = "/";
        }
        {
          type = "battery";
          key = "󰁹 Battery";
        }
        {
          type = "media";
          key = "󰝚 Media";
        }
        "break"
        {
          type = "colors";
          symbol = "circle";
        }
      ];
    };
  };

  programs.fish.functions.fish_greeting = "fastfetch";
}
