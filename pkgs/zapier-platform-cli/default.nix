{
  lib,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "zapier-platform-cli";
  version = "18.3.0";

  src = ./.;

  npmDepsHash = "sha256-S7HL/AfeJVMtHbwED6eXmT5Dkfg2rkZqb718KEQUs4g=";
  dontNpmBuild = true;

  postInstall = ''
    mkdir -p $out/bin
    ln -s $out/lib/node_modules/zapier-platform-cli-wrapper/node_modules/.bin/zapier $out/bin/zapier
  '';

  meta = with lib; {
    description = "CLI for the Zapier Developer Platform";
    homepage = "https://github.com/zapier/zapier-platform";
    license = licenses.unfree;
    mainProgram = "zapier";
  };
}
