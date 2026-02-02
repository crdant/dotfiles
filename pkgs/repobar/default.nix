{ fetchzip, lib, stdenv, darwin }:

stdenv.mkDerivation rec {
  pname = "repobar";
  version = "0.2.0";

  src = fetchzip {
    url = "https://github.com/steipete/RepoBar/releases/download/v${version}/RepoBar-${version}.zip";
    sha256 = "sha256-5CWcgHghUwC5xBnFMVSP0/S246w//NlYUzoLP8kManc=";
    stripRoot = false;
  };

  dontFixup = true;

  nativeBuildInputs = [ darwin.xattr ];

  installPhase = ''
    runHook preInstall
    APP_DIR="$out/Applications/RepoBar.app"
    mkdir -p $APP_DIR
    for file in RepoBar.app/*; do
      mv "$file" "$APP_DIR"
      if [ -f "$file" ]; then
        xattr -w com.apple.ResourceFork "$(cat __MACOSX/RepoBar.app/._*/../$file)" "$APP_DIR/$file" 2>/dev/null || true
      fi
    done
    rm -rf __MACOSX
    runHook postInstall
  '';

  meta = with lib; {
    description = "Show status of GitHub Repos right in your menu bar and terminal: CI, Issues, Pull Requests, Latest Release.";
    homepage = "repobar.app";
    license = licenses.mit;
    platforms = [ "x86_64-darwin" "aarch64-darwin" ];
  };
}
