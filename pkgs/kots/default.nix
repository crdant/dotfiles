{ stdenv, lib, pkgs, buildGoModule, fetchFromGitHub, installShellFiles, pkg-config, bash }:

buildGoModule rec {
  pname = "kots";
  version = "1.112.4";

  src = fetchFromGitHub {
    owner = "replicatedhq";
    repo = "kots";
    rev = "v${version}";
    sha256 = "sha256-MX8HUnlPJ+gocB5jZ5D3QraPb5UwFU0PPY2bOyjufdQ=";
  };

  vendorHash = "sha256-tcPdzicrtWGXDsELKF3Bd+/pTVYP2uuYAE0Vj5Ujil8="; 

  subPackages = [ "cmd/kots/" ];

  ldflags = [
    "-X github.com/replicatedhq/kots/pkg/buildversion.version=${version}"
    "-X github.com/replicatedhq/kots/pkg/buildversion.gitCommit=${src.rev}"
  ];

  ldflagsStr = lib.strings.concatStringsSep " " ldflags ;

  # Override build phase to use make
  buildPhase = ''
    runHook preBuild
    make SHELL='${bash}/bin/bash -o pipefail' LDFLAGS='-ldflags "${ldflagsStr}"' kots-real
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
