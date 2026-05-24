{
  lib,
  buildNpmPackage,
  fetchurl,
  runCommand,
  nodejs,
  cacert,
}:

let
  version = "0.5.6";

  tarball = fetchurl {
    url = "https://registry.npmjs.org/@readwise/cli/-/cli-${version}.tgz";
    hash = "sha256-Hrf6Tng7dRRRzyWopaJ+5PQYD2EtUsdta5Iw98e4BuY=";
  };

  # Fixed-output derivation: generates the lockfile from the package's own
  # package.json at build time. No lockfile committed to the repo.
  # To update: set lockHash = lib.fakeHash, build, copy the hash from the error.
  lockHash = "sha256-ctZDqmv0Jug171Tb6uBfo3n097YtQ00nbnhgbQmHs84=";
  packageLock = runCommand "readwise-cli-lockfile-${version}" {
    nativeBuildInputs = [ nodejs cacert ];
    SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
    outputHashAlgo = "sha256";
    outputHashMode = "flat";
    outputHash = lockHash;
  } ''
    tar xzf ${tarball} --strip-components=1
    HOME=$TMPDIR npm install --package-lock-only --ignore-scripts
    cp package-lock.json $out
  '';
in
buildNpmPackage rec {
  pname = "readwise-cli";
  inherit version;

  src = tarball;

  postPatch = ''
    cp ${packageLock} package-lock.json
  '';

  npmDepsHash = "sha256-HOdNw7ahKvVMb5cOqZ8UgUNWivLlJAQqZuN6fijoTyc=";
  dontNpmBuild = true;

  meta = with lib; {
    description = "CLI for Readwise";
    homepage = "https://www.npmjs.com/package/@readwise/cli";
    license = licenses.unfree;
    mainProgram = "readwise";
  };
}
