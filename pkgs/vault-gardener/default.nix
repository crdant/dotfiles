{
  lib,
  fetchurl,
  buildNpmPackage,
}:

let
  version = "0.3.1";

  tarball = fetchurl {
    url = "https://registry.npmjs.org/vault-gardener/-/vault-gardener-${version}.tgz";
    hash = "sha256-JvyqPeEI9hidSvX4A7bFvbLEbTPn7A59TByFUZ1fJ6k=";
  };
in

buildNpmPackage {
  pname = "vault-gardener";
  inherit version;

  src = tarball;

  # Lockfile is vendored in this directory (package-lock.json) rather than
  # generated at build time, so npmDepsHash stays stable.
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
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
