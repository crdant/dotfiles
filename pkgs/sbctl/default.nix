{ stdenv, lib, buildGoModule, fetchFromGitHub, installShellFiles }:

buildGoModule rec {
  pname = "troubeleshoot-sbctl";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "replicatedhq";
    repo = "sbctl";
    rev = "v${version}";
    sha256 = "sha256-D1lNFVGQqMWn0OgD7WTnDg2E54JRI/ZjG1MSpmvQ4uA=";
  };

  vendorHash = "sha256-kW21GdJ/eYee5/HUG6AlrkCpfzjvmQY8xFX71QQKpVk=";

  # Override build phase to use make
  buildPhase = ''
    runHook preBuild
    export GOPROXY=https://proxy.golang.org,direct
    make build 
    runHook postBuild
  '';

  # Install the binary
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp bin/sbctl $out/bin/sbctl
    runHook postInstall
  '';

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    $out/bin/sbctl completion bash > sbctl.bash
    $out/bin/sbctl completion zsh > sbctl.zsh
    $out/bin/sbctl completion fish > sbctl.fish
    installShellCompletion sbctl.{bash,zsh,fish}
  '';

  meta = with lib; {
    homepage = "https://github.com/replicatedhq/sbctl";
    description = "Command line tool for examining K8s resources in Troubleshoot's support bundles";
    mainProgram = "sbctl";
    license = licenses.asl20;
  };

}
