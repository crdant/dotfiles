{ stdenv, lib, buildGoModule, fetchFromGitHub, installShellFiles }:
let
  isDarwin = stdenv.isDarwin;
  isLinux = stdenv.isLinux;
in
buildGoModule rec {
  pname = "replicated";
  version = "0.97.0";

  src = fetchFromGitHub {
    owner = "replicatedhq";
    repo = "replicated";
    rev = "v${version}";
    sha256 = "sha256-btq8ag3UlcTC7NMIpI7DiFUPSa5ZKYV1FD67t05venk=";
  };

  vendorHash = if isDarwin then
      "sha256-OYm8Jd0kLRU3K4fb6kPoPiCJClpger9JSZVoY5WEriQ="
    else
      "";

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
