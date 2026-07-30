{
  lib,
  fetchurl,
  nodejs,
  buildNpmPackage,
  runCommand,
  cacert,
}:

let
  version = "0.3.1";

  tarball = fetchurl {
    url = "https://registry.npmjs.org/vault-gardener/-/vault-gardener-${version}.tgz";
    hash = "sha256-JvyqPeEI9hidSvX4A7bFvbLEbTPn7A59TByFUZ1fJ6k=";
  };

  packageLock = runCommand "vault-gardener-lockfile-${version}" {
    nativeBuildInputs = [ nodejs cacert ];
    outputHashAlgo = "sha256";
    outputHashMode = "flat";
    outputHash = "sha256-hjF3p5pNtAox5bo8ZqQg5CBTmjxdPLwmPdOFdCERF1g=";
  } ''
    tar xzf ${tarball} --strip-components=1
    HOME=$TMPDIR npm install --package-lock-only --ignore-scripts
    cp package-lock.json $out
  '';
in

buildNpmPackage {
  pname = "vault-gardener";
  inherit version;

  src = tarball;

  postPatch = ''
    cp ${packageLock} package-lock.json
  '';

  npmDepsHash = "sha256-7+aIZ4FFYLw79jSDioRg0Ds1zwF6i/9V9CnEszXCXdI=";

  dontNpmBuild = true;

  meta = with lib; {
    description = "AI-powered vault maintenance pipeline for markdown knowledge bases";
    homepage = "https://www.npmjs.com/package/vault-gardener";
    license = licenses.mit;
    mainProgram = "vault-gardener";
  };
}
