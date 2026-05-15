{ lib, stdenv, fetchFromGitHub, nodejs, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "claude-memory-extractor";
  version = "unstable-2025-01-20";

  src = fetchFromGitHub {
    owner = "obra";
    repo = "claude-memory-extractor";
    rev = "384e0302088639cf9a3d40d92cf57e44e25f9044";
    hash = "sha256-lvYit/IZwbHhxU3/jlzHL1AMkJ46BGpoYRnSuovDNhs=";
  };

  nativeBuildInputs = [ nodejs makeWrapper ];

  # Using __noChroot due to buildNpmPackage limitations:
  # The upstream package-lock.json is stale (renamed from "claude-introspection" to
  # "claude-memory" but lock file not regenerated). Even with a corrected lock file,
  # buildNpmPackage's prefetch-npm-deps only caches ~50 of 483 dependencies, causing
  # ENOTCACHED errors. This appears to be a prefetch-npm-deps limitation with
  # lockfileVersion 3 packages.
  #
  # The source is pinned to a specific commit SHA for reproducibility.
  __noChroot = true;

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR
    npm ci --prefer-offline --no-audit
    npm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/claude-memory-extractor
    cp -r . $out/lib/node_modules/claude-memory-extractor

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/claude-memory \
      --add-flags "$out/lib/node_modules/claude-memory-extractor/dist/cli.js"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Multi-dimensional memory extraction system for Claude Code conversation logs";
    longDescription = ''
      A tool that processes Claude Code conversation logs to extract transferable lessons
      using multi-dimensional analysis including root cause analysis, psychological driver
      identification, and prevention strategies.
    '';
    homepage = "https://github.com/obra/claude-memory-extractor";
    license = licenses.mit;
    maintainers = [];
    mainProgram = "claude-memory";
    platforms = platforms.unix;
  };
}
