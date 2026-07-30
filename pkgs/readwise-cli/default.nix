{
  lib,
  buildNpmPackage,
  fetchurl,
}:

let
  version = "0.5.6";

  tarball = fetchurl {
    url = "https://registry.npmjs.org/@readwise/cli/-/cli-${version}.tgz";
    hash = "sha256-Hrf6Tng7dRRRzyWopaJ+5PQYD2EtUsdta5Iw98e4BuY=";
  };
in
buildNpmPackage rec {
  pname = "readwise-cli";
  inherit version;

  src = tarball;

  # Lockfile is vendored in this directory (package-lock.json) rather than
  # generated at build time, so npmDepsHash stays stable.
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-zsEAUEmOEchpDxhstKYLr2sxX9fNmMmtKaj2IvqcCAw=";
  dontNpmBuild = true;

  meta = with lib; {
    description = "CLI for Readwise";
    homepage = "https://www.npmjs.com/package/@readwise/cli";
    license = licenses.unfree;
    mainProgram = "readwise";
  };
}
