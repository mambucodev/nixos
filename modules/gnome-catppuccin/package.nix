{ stdenv, fetchFromGitHub, python3, gnome-shell }:

stdenv.mkDerivation {
  pname = "gnome-catppuccin-mocha";
  version = "v1.0";

  src = fetchFromGitHub {
    owner = "elisesouche";
    repo = "gnome-catppuccin";
    rev = "v1.0";
    fetchSubmodules = true;
    hash = "sha256-R/pIVO8I3d5cAhgGSHthOpjHEo1Oxbaepb30raxWRnc=";
  };

  nativeBuildInputs = [
    (python3.withPackages (ps: with ps; [ libsass diff-match-patch ]))
  ];

  # The pinned gnome-shell submodule predates GNOME 50 (no styles for e.g. the
  # login screen's a11y button), so build against the shell actually in use.
  postPatch = ''
    rm -rf gnome-shell
    mkdir gnome-shell
    tar -xf ${gnome-shell.src} --strip-components=1 -C gnome-shell
  '';

  buildPhase = ''
    runHook preBuild
    python3 ./build.py
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/themes
    mv _build/theme $out/share/themes/gnome-catppuccin
    runHook postInstall
  '';
}
