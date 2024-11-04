{ stdenv, lib, buildGoModule, fetchFromGitHub, installShellFiles }:

buildGoModule rec {
  pname = "replicated";
  version = "0.83.13";

  src = fetchFromGitHub {
    owner = "replicatedhq";
    repo = "replicated";
    rev = "v${version}";
    sha256 = "sha256-BTgxlCWCg7fzmfUu8VEKCvKW9IN5h3DrS88ExC62MQU=";
  };

  vendorHash = "sha256-YMIB8GAX3DpZ8eazEugOeoLD4Yp84kbWuZdYBG4IWbw=";

  subPackages = [ "cli/cmd/" ];
  ldflags = [
    "-X github.com/replicatedhq/replicated/pkg/version.version=${version}"
    "-X github.com/replicatedhq/replicated/pkg/version.gitCommit=${src.rev}"
  ];

  ldflagsStr = lib.strings.concatStringsSep " " ldflags ;

  # Override build phase to use make
  buildPhase = ''
    export HOME=$(pwd)
    runHook preBuild
    make LDFLAGS='-ldflags "${ldflagsStr}"' build
    runHook postBuild
  '';

  # Install the binary
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp bin/replicated $out/bin/
    runHook postInstall
  '';

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    $out/bin/replicated completion bash > replicated.bash
    $out/bin/replicated completion zsh > replicated.zsh
    $out/bin/replicated completion fish > replicated.fish
    installShellCompletion replicated.{bash,zsh,fish}
  '';

  meta = with lib; {
    homepage = "https://github.com/replicatedhq/replicated";
    description = "A CLI to create, edit and promote releases for the Replicated platform";
    mainProgram = "replicated";
    license = licenses.mit;
  };
}
