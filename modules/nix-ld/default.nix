{ ... }:

{
  # Claude Desktop's in-app Claude Code downloads its own generic-linux `claude`
  # (a Bun executable needing only glibc) and ignores the Nix one on PATH.
  # nix-ld supplies the /lib64 loader it expects.
  programs.nix-ld.enable = true;
}
