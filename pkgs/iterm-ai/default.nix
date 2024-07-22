{ fetchzip, lib, stdenv }:

stdenv.mkDerivation rec {
  pname = "iterm-ai";
  version = "1.1";

  src = fetchzip {
    url = "https://iterm2.com/downloads/ai-plugin/iTermAI-${version}.zip";
    sha256 = "sha256-CLYnXRavvT526UTd0P+lFEQQmdtD6c+A13aX7fYWgjE=";
  };

  dontFixup = true;

  installPhase = ''
    runHook preInstall
    APP_DIR="$out/Applications/iTermAI.app"
    mkdir -p "$APP_DIR"
    cp -r . "$APP_DIR"
    runHook postInstall
  '';

  meta = with lib; {
    description = "An optiontional component to enable generative AI features in iTerm2";
    homepage = "https://iterm2.com/ai-plugin.html";
    platforms = [ "aarch64-darwin" ];
  };
}
