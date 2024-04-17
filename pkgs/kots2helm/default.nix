{ stdenv, lib, buildGoModule, fetchFromGitHub, installShellFiles }:

buildGoModule rec {
  pname = "kots2helm";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "replicatedhq";
    repo = "kots2helm";
    rev = "v${version}";
    sha256 = "08a1wdkn4bp784ksmc8l9hrqmagp5qj4pbjd4pwax796fbgrvd4z";
  };

  vendorHash = "sha256-oeWu84qw1PyI6R4YXGZIAGMvU7QZY+DOLzFf6qAqOCI=";

  ldflags = [
    "-X github.com/replicatedhq/kots/pkg/buildversion.version=${version}"
    "-X github.com/replicatedhq/kots/pkg/buildversion.gitSHA=${src.rev}"
  ];

  ldflagsStr = lib.strings.concatStringsSep " " ldflags ;

  # Override build phase to use make
  buildPhase = ''
    runHook preBuild
    export GO111MODULE=on
    export GOPROXY=https://proxy.golang.org,direct
    make LDFLAGS='-ldflags "${ldflagsStr}"' all 
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp bin/kots2helm $out/bin/kots2helm
    runHook postInstall
  '';

  nativeBuildInputs = [ installShellFiles ];

  meta = with lib; {
    homepage = "https://github.com/replicatedhq/kots2helm";
    description = "This is an experimental CLI that attempts to convert a KOTS application to a Helm chart.";
    mainProgram = "kots2helm";
  };

}
