{ stdenv, lib, pkgs, buildGoModule, fetchFromGitHub, installShellFiles, pkg-config, bash }:
let
  isDarwin = stdenv.isDarwin;
  isLinux = stdenv.isLinux;
in
buildGoModule rec {
  pname = "kots";
  version = "1.129.3";

  src = fetchFromGitHub {
    owner = "replicatedhq";
    repo = "kots";
    rev = "v${version}";
    sha256 = "sha256-rTUYGM0Z2jBTrbSmLocKj1iB4+efn9eWMjr1DB6F/1c=";
  };

  vendorHash = if isDarwin then 
      "sha256-ThgM4tfK12bHR1u8paZEifRSPDejcJwDwWwHtjYQQjk="
    else
      "sha256-RBIHqKg/BEqgVVzyQSTNk5s9rHLMvw+KnM123j2Mpr0=";

  subPackages = [ "cmd/kots/" ];

  ldflags = [
    "-X github.com/replicatedhq/kots/pkg/buildversion.version=${version}"
    "-X github.com/replicatedhq/kots/pkg/buildversion.gitCommit=${src.rev}"
  ];

  ldflagsStr = lib.strings.concatStringsSep " " ldflags ;

  # Override build phase to use make
  buildPhase = ''
    runHook preBuild
    make SHELL='${bash}/bin/bash -o pipefail' LDFLAGS='-ldflags "${ldflagsStr}"' kots
    runHook postBuild
  '';

  # Install the binary
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp bin/kots $out/bin/kubectl-kots
    runHook postInstall
  '';

  nativeBuildInputs = [ installShellFiles pkg-config ];

  postInstall = ''
    $out/bin/kubectl-kots completion bash > kubectl-kots.bash
    $out/bin/kubectl-kots completion zsh > kubectl-kots.zsh
    $out/bin/kubectl-kots completion fish > kubectl-kots.fish
    installShellCompletion kubectl-kots.{bash,zsh,fish}
  '';

  meta = with lib; {
    homepage = "https://github.com/replicatedhq/kots";
    description = "KOTS provides the framework, tools and integrations that enable the delivery and management of 3rd-party Kubernetes applications, a.k.a. Kubernetes Off-The-Shelf (KOTS) Software.";
    mainProgram = "kubectl-kots";
    license = licenses.asl20;
  };
}
