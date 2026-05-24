{
  lib,
  stdenv,
  fetchurl,
  nodejs,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "vault-gardener";
  version = "0.3.1";

  src = fetchurl {
    url = "https://registry.npmjs.org/vault-gardener/-/vault-gardener-${version}.tgz";
    hash = "sha256-JvyqPeEI9hidSvX4A7bFvbLEbTPn7A59TByFUZ1fJ6k=";
  };

  nativeBuildInputs = [ makeWrapper ];

  # dist/bin/vault-gardener.js is a fully bundled tsup build — no node_modules needed
  installPhase = ''
    mkdir -p $out/lib/vault-gardener
    cp -r dist $out/lib/vault-gardener/
    makeWrapper ${nodejs}/bin/node $out/bin/vault-gardener \
      --add-flags "$out/lib/vault-gardener/dist/bin/vault-gardener.js"
  '';

  meta = with lib; {
    description = "AI-powered vault maintenance pipeline for markdown knowledge bases";
    homepage = "https://www.npmjs.com/package/vault-gardener";
    license = licenses.mit;
    mainProgram = "vault-gardener";
  };
}
