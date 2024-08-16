{ fetchurl, lib, stdenv }:

stdenv.mkDerivation rec {
  pname = "vimr";
  version = "v0.48.0";
  build = "20240727.082947";

  src = fetchurl {
    url = "https://github.com/qvacua/vimr/releases/download/${version}-${build}/VimR-v0.48.0.tar.bz2";
    sha256 = "sha256-0hkVEHODIzJ6iTpRaAlaqSjdi9Tlj7kN4tFOZ7RxkCg=";
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
