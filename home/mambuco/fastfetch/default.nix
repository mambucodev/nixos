{ ... }:

let
  # catppuccin/nix has no fastfetch port — Macchiato colors as 24-bit SGR
  c = r: g: b: "38;2;${toString r};${toString g};${toString b}";
  p = {
    blue = c 138 173 244;
    lavender = c 183 189 248;
    mauve = c 198 160 246;
    text = c 202 211 245;
    overlay = c 110 115 141;
    surface = c 91 96 120;
  };
in
{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "nixos_old_small";
        padding = { top = 3; left = 2; right = 4; };
        color = { "1" = p.blue; "2" = p.lavender; };
      };
      display = {
        separator = " ";
        brightColor = false;
        key.width = 10;
        color = { keys = p.overlay; output = p.text; };
        bar = {
          width = 12;
          char = { elapsed = "━"; total = "━"; };
          border = { left = ""; right = ""; };
          color = { elapsed = p.blue; total = p.surface; };
        };
        percent.type = [ "num" "bar" ];
      };
      modules = [
        { type = "title"; format = "{#${p.blue}}{host-name}{#${p.overlay}} · {user-name}"; }
        "break"
        { type = "custom"; format = "{#${p.surface}}╭─{#${p.mauve}} system"; }
        { type = "os"; key = "│ os"; format = "{name} {version-id}"; }
        { type = "kernel"; key = "│ kernel"; format = "{release}"; }
        { type = "uptime"; key = "│ uptime"; }
        { type = "packages"; key = "│ pkgs"; format = "{nix-system} sys · {nix-user} user"; }
        { type = "custom"; format = "{#${p.surface}}├─{#${p.mauve}} desktop"; }
        { type = "de"; key = "│ de"; format = "{pretty-name} {version}"; }
        { type = "shell"; key = "│ shell"; format = "{pretty-name} {version}"; }
        { type = "terminal"; key = "│ term"; format = "{pretty-name}"; }
        { type = "custom"; format = "{#${p.surface}}├─{#${p.mauve}} hardware"; }
        { type = "cpu"; key = "│ cpu"; format = "{name} · {cores-logical}t"; }
        { type = "memory"; key = "│ mem"; format = "{percentage-bar}  {used}"; }
        { type = "disk"; key = "│ disk"; folders = "/"; format = "{size-percentage-bar}  {size-used}"; }
        { type = "battery"; key = "╰ bat"; format = "{capacity-bar}  {capacity}"; }
        "break"
        { type = "colors"; symbol = "square"; }
      ];
    };
  };

  programs.fish.functions.fish_greeting = "fastfetch";
}
