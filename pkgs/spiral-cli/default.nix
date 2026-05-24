{
  lib,
  stdenv,
  fetchurl,
  nodejs,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "spiral-cli";
  version = "1.5.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/@every-env/spiral-cli/-/spiral-cli-${version}.tgz";
    hash = "sha256-v3t/B0eoda4mYNEP0OZmBG91GL4BVwZawJM2ucCOe64=";
  };

  nativeBuildInputs = [ makeWrapper ];

  # dist/cli.mjs is a fully bundled bun build — no node_modules needed at runtime
  installPhase = ''
    mkdir -p $out/lib/spiral
    cp -r bin dist $out/lib/spiral/
    makeWrapper ${nodejs}/bin/node $out/bin/spiral \
      --add-flags "$out/lib/spiral/bin/spiral.mjs"
  '';

  meta = with lib; {
    description = "CLI for the Spiral writing tool";
    homepage = "https://www.npmjs.com/package/@every-env/spiral-cli";
    license = licenses.unfree;
    mainProgram = "spiral";
  };
}
