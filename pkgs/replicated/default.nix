{ stdenv, lib, buildGoModule, fetchFromGitHub, installShellFiles }:

buildGoModule rec {
  pname = "replicated";
  version = "0.71.0";

  src = fetchFromGitHub {
    owner = "replicatedhq";
    repo = "replicated";
    rev = "v${version}";
    sha256 = "bShKx+68bfKu5ZBeTBIo0agk37aLIA39NcYauBILMUY=";
  };

  vendorHash = "sha256-WEx7ozGY7dJVR47iZF0OTBvTBTYKUDTals85Se4z5l4=";

  subPackages = [ "cli/cmd/" ];
  ldflags = [
    "-X github.com/replicatedhq/replicated/pkg/version.version=${version}"
    "-X github.com/replicatedhq/replicated/pkg/version.gitCommit=${src.rev}"
  ];

  ldflagsStr = lib.strings.concatStringsSep " " ldflags ;

  # Override build phase to use make
  buildPhase = ''
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
