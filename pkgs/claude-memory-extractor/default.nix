{ lib, stdenv, fetchFromGitHub, nodejs, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "claude-memory-extractor";
  version = "unstable-2025-01-20";

  src = fetchFromGitHub {
    owner = "obra";
    repo = "claude-memory-extractor";
    rev = "main";
    hash = "sha256-lvYit/IZwbHhxU3/jlzHL1AMkJ46BGpoYRnSuovDNhs=";
  };

  nativeBuildInputs = [ nodejs makeWrapper ];

  # Disable sandbox to allow npm install from registry
  # This is a temporary workaround for npm package builds
  __noChroot = true;

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR
    npm install --legacy-peer-deps
    npm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/claude-memory
    cp -r . $out/lib/node_modules/claude-memory

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/claude-memory \
      --add-flags "$out/lib/node_modules/claude-memory/dist/cli.js"

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
