{
  lib,
  buildNpmPackage,
  fetchurl,
  nix-update-script,
}:

let
  version = "0.5.11";

  tarball = fetchurl {
    url = "https://registry.npmjs.org/@readwise/cli/-/cli-${version}.tgz";
    hash = "sha256-0dP8pVZpOBPm04rKsTRjQGJVN9PHZkLvXVPdTm+MOQw=";
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

  npmDepsHash = "sha256-n/RFUFnfej8AHrjMxdHoyfvs9H7Cyj8URxXDb/HG86I=";
  dontNpmBuild = true;

  passthru.updateScript = nix-update-script { extraArgs = [ "--generate-lockfile" ]; };

  meta = with lib; {
    description = "CLI for Readwise";
    homepage = "https://www.npmjs.com/package/@readwise/cli";
    license = licenses.unfree;
    mainProgram = "readwise";
  };
}
