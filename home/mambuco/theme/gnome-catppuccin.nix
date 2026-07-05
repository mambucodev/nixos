{ pkgs, ... }:

let
  gnome-catppuccin-macchiato = pkgs.stdenv.mkDerivation {
    pname = "gnome-catppuccin-macchiato";
    version = "v1.0";

    src = pkgs.fetchFromGitHub {
      owner = "elisesouche";
      repo = "gnome-catppuccin";
      rev = "v1.0";
      fetchSubmodules = true;
      hash = "sha256-R/pIVO8I3d5cAhgGSHthOpjHEo1Oxbaepb30raxWRnc=";
    };

    nativeBuildInputs = [
      (pkgs.python3.withPackages (ps: with ps; [ libsass diff-match-patch ]))
    ];

    # Upstream ships only Mocha. Remap Mocha→Macchiato, but in palette.scss only
    # the mappings (refs ending in `;`), not the later Mocha definitions.
    postPatch = ''
      sed -i 's/\$mocha\(-[a-z0-9]\+\);/$macchiato\1;/g' palette.scss
      sed -i 's/\$mocha-/$macchiato-/g' default-colors.scss.patch colors.scss.patch
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
  };
in
{
  home.packages = with pkgs; [
    gnome-catppuccin-macchiato
    gnomeExtensions.user-themes
  ];
}
