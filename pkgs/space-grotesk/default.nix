{ lib, stdenvNoCC, fetchzip }:

stdenvNoCC.mkDerivation rec {
  pname = "space-grotesk";
  version = "2.0.0";

  src = fetchzip {
    url = "https://github.com/floriankarsten/space-grotesk/releases/download/${version}/SpaceGrotesk-${version}.zip";
    hash = "sha256-niwd5E3rJdGmoyIFdNcK5M9A9P2rCbpsyZCl7CDv7I8=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 SpaceGrotesk-${version}/ttf/SpaceGrotesk\[wght\].ttf \
      -t $out/share/fonts/truetype

    runHook postInstall
  '';

  meta = with lib; {
    description = "Proportional variable typeface derived from Space Mono";
    homepage = "https://github.com/floriankarsten/space-grotesk";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
