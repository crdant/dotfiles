{ fetchurl, lib, stdenv }:

stdenv.mkDerivation rec {
  pname = "vimr";
  version = "v0.46.1";
  build = "20240114.181346";

  src = fetchurl {
    url = "https://github.com/qvacua/vimr/releases/download/${version}-${build}/VimR-v0.46.1.tar.bz2";
    sha256 = "33aabbe736045f9901e89cef3fde7d8a758f39efca039ba7873c7961b79ee53a";
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
