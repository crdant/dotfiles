{ stdenv, lib, buildGoModule, fetchFromGitHub, installShellFiles }:
let
  isDarwin = stdenv.isDarwin;
  isLinux = stdenv.isLinux;
in
buildGoModule rec {
  pname = "replicated";
  version = "0.115.1";

  src = fetchFromGitHub {
    owner = "replicatedhq";
    repo = "replicated";
    rev = "v${version}";
    sha256 = "sha256-N6mASGZiWiPuwMGjqhUJ9/ivyOk27PZv2pbkO0WhAuQ=";
  };

  vendorHash = if isDarwin then
      "sha256-ufbL6ddpACgaimmz5tEAMAVYO22Am560imDg8SVKBr4="
    else
      "sha256-ufbL6ddpACgaimmz5tEAMAVYO22Am560imDg8SVKBr4=";

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
