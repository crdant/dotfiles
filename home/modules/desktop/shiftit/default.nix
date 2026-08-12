{ stdenv, glib }:

stdenv.mkDerivation {
  pname = "gnome-shell-extension-shiftit";
  version = "0.1.0";

  src = ./src;

  nativeBuildInputs = [ glib ];

  buildPhase = ''
    runHook preBuild
    glib-compile-schemas schemas
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/gnome-shell/extensions/shiftit@shortrib.io
    cp -r extension.js metadata.json schemas \
      $out/share/gnome-shell/extensions/shiftit@shortrib.io/
    runHook postInstall
  '';
}
