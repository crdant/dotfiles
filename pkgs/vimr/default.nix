{ fetchurl, lib, stdenv }:

stdenv.mkDerivation rec {
  pname = "vimr";
  version = "v0.57.1";
  build = "20250921.204618";

  src = fetchurl {
    url = "https://github.com/qvacua/vimr/releases/download/${version}-${build}/VimR-${version}.tar.bz2";
    sha256 = "sha256-ojYpD5aEy3M0D4TJPmPrWqmfQWLOV7LRGPY1WLmE+ZI=";
  };

  dontFixup = true;

  installPhase = ''
    runHook preInstall
    APP_DIR="$out/Applications/VimR.app"
    mkdir -p "$APP_DIR"
    cp -r . "$APP_DIR"
    runHook postInstall
  '';

  meta = with lib; {
    description = "VimR — Neovim GUI for macOS in Swift";
    homepage = "https://twitter.com/VimRefined";
    license = licenses.mit;
    platforms = [ "x86_64-darwin" "aarch64-darwin" ];
  };
}
