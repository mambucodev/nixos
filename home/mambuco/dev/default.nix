{ pkgs, ... }:

{
  programs.go.enable = true;

  home.packages = with pkgs; [
    # rust
    rustc
    cargo
    rust-analyzer
    clippy
    rustfmt

    # go (programs.go adds the binary; this adds the LSP)
    gopls

    # other languages
    bun
    deno
    nodejs
    yarn-berry
    jdk25
    gradle

    # python
    (python3.withPackages (ps: with ps; [ ipython ]))
    uv
    ruff
    pyright

    # build tools
    gcc
    cmake
    gnumake
    gdb
    pkgconf

    # dev utilities
    git-filter-repo
    scrcpy
  ];
}
