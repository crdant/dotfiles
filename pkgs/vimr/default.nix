{ neovim, vimUtils, fetchurl, lib, stdenv, makeWrapper }:

 /*
 This cannot be built from source as it requires entitlements and
 for that it needs to be code signed. Automatic updates will have
 to be disabled via preferences instead of at build time. To do
 that edit $HOME/Library/Preferences/com.googlecode.iterm2.plist
 and add:
 SUEnableAutomaticChecks = 0;
 */
let 
  wrapperArgs = neovim.wrapperArgs  ;
  neovimArgs = "--add-flags '--nvim' --add-flags '--cmd \"set packpath^=${vimUtils.packDir neovim.packpathDirs}\"' --add-flags '--cmd \"set rtp^=${vimUtils.packDir neovim.packpathDirs}\"'";
in stdenv.mkDerivation rec {
  pname = "vimr";
  version = "v0.46.1";
  build = "20240114.181346";

  src = fetchurl {
    url = "https://github.com/qvacua/vimr/releases/download/${version}-${build}/VimR-v0.46.1.tar.bz2";
    sha256 = "33aabbe736045f9901e89cef3fde7d8a758f39efca039ba7873c7961b79ee53a";
  };

  dontFixup = true;

  buildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    APP_DIR="$out/Applications/VimR.app"
    mkdir -p "$APP_DIR"
    cp -r . "$APP_DIR"
    mkdir -p "$out/bin"

    # Create a wrapper for the CLI
    makeWrapper $APP_DIR/Contents/Resources/vimr $out/bin/vimr ${wrapperArgs} \
      ${neovimArgs}
    chmod +x "$out/bin/vimr"
    runHook postInstall
  '';

  meta = with lib; {
    description = "VimR — Neovim GUI for macOS in Swift";
    homepage = "https://twitter.com/VimRefined";
    license = licenses.mit;
    platforms = [ "x86_64-darwin" "aarch64-darwin" ];
  };
}
